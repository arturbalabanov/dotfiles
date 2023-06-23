local status_ok, project_nvim = pcall(require, "project_nvim.project")
if not status_ok then
    return
end

local Path = require("plenary.path")
local plenary_tbl = require("plenary.tbl")

local my_utils = require("user.utils")

local M = {}

local function pipenv_get_python_path(project_root)
    local output = my_utils.run_shell_cmd('pipenv --venv', { cwd = project_root })

    if output == nil then
        return nil
    end

    local output_lines = vim.split(output, '\n')
    local venv_path = output_lines[#output_lines]

    return Path:new(venv_path):joinpath('bin', 'python'):expand()
end

local function pdm_get_python_path(project_root)
    return my_utils.run_shell_cmd('pdm venv --python in-project', { cwd = project_root })
end

local function poetry_get_python_path(project_root)
    local venv_path = my_utils.run_shell_cmd('poetry env info -p', { cwd = project_root })

    if venv_path == nil then
        return nil
    end

    return Path:new(venv_path):joinpath('bin', 'python'):expand()
end

local function file_present_in_proj_checker(file_name)
    return function(project_root)
        local match = vim.fn.glob(Path:new(project_root):joinpath(file_name):expand())
        return match ~= ''
    end
end

M.default_venv_managers = {
    {
        name = "Pipenv",
        executable_name = 'pipenv',
        is_managing_proj_func = file_present_in_proj_checker('Pipfile.lock'),
        get_python_path_func = pipenv_get_python_path,
    },
    {
        name = "PDM",
        executable_name = 'pdm',
        is_managing_proj_func = file_present_in_proj_checker('pdm.lock'),
        get_python_path_func = pdm_get_python_path,
    },
    {
        name = 'Poetry',
        executable_name = 'poetry',
        is_managing_proj_func = file_present_in_proj_checker('poetry.lock'),
        get_python_path_func = poetry_get_python_path,
    },
    -- TODO: Add support for hatch
    -- TODO: Add support for the buit in python venv manager (python -m venv)
    -- TODO: Add support for virtualenvwrapper
    -- TODO: Add support for conda

}

local venv_managers = {}

for _, venv_manager in pairs(M.default_venv_managers) do
    if my_utils.executable_exists(venv_manager.executable_name) then
        table.insert(venv_managers, venv_manager)
    end
end

function get_venv_manager(project_root)
    for _, venv_manager in pairs(venv_managers) do
        if venv_manager.is_managing_proj_func(project_root) then
            return venv_manager
        end
    end

    return nil
end

local function detect_venv_python_path_no_cache(project_root, opts)
    local opts = plenary_tbl.apply_defaults(opts, { disable_notifications = false, venv_manager = nil })

    if vim.env.VIRTUAL_ENV then
        if not opts.disable_notifications then
            my_utils.simple_notify("Using activated venv" .. vim.env.VIRTUAL_ENV, "info")
        end

        return Path:new(vim.env.VIRTUAL_ENV):joinpath('bin', 'python'):expand()
    end

    local venv_manager = opts.venv_manager

    if venv_manager == nil then
        venv_manager = get_venv_manager(project_root)

        if venv_manager == nil then
            return nil
        end
    end

    return venv_manager.get_python_path_func(project_root)
end

local project_python_path_cache = {}

function M.get_project_venv_python_path(project_root, opts)
    local opts = plenary_tbl.apply_defaults(opts, { disable_notifications = false, venv_manager = nil })

    if project_python_path_cache[project_root] == nil then
        project_python_path_cache[project_root] = detect_venv_python_path_no_cache(project_root, opts)
    end

    return project_python_path_cache[project_root]
end

local venvs_per_buf_cache = {}

local function get_python_path_no_cache(bufnr, opts)
    local opts = plenary_tbl.apply_defaults(opts,
        { disable_notifications = false, fallback_to_system_python = false, venv_manager = nil })

    local project_root = project_nvim.find_pattern_root()
    local project_name = vim.fn.fnamemodify(project_root, ':t')

    if opts.venv_manager == nil then
        opts.venv_manager = get_venv_manager(project_root)

        if opts.venv_manager == nil then
            if not opts.fallback_to_system_python then
                if not opts.disable_notifications then
                    local msg = "No venv was found for " .. project_root .. "and fallback to system python is disabled"
                    my_utils.simple_notify(msg, "error")
                end

                return nil
            end
        end
    end

    local venv_manager = opts.venv_manager

    local venv_python_path = M.get_project_venv_python_path(project_root, opts)
    local venv_name
    local python_path

    if venv_python_path == nil then
        if not opts.disable_notifications then
            local msg = "No virtual environment found in " .. project_root

            if opts.fallback_to_system_python then
                msg = msg .. ", falling back to system python"
            end

            my_utils.simple_notify(msg, "warn")
        end

        if not opts.fallback_to_system_python then
            return nil
        end

        venv_name = nil
        python_path = vim.loop.exepath('python3') or vim.loop.exepath('python') or 'python'
    else
        python_path = venv_python_path
        -- :h is the parent
        -- :t is the last component
        -- The pythonpath is <venv-path>/bin/python

        local venv_dir_path = vim.fn.fnamemodify(python_path, ":h:h")
        local venv_dir_name = vim.fn.fnamemodify(venv_dir_path, ":t")

        -- TODO: If the venv manager supports getting the venv name, use that instead

        if venv_dir_name == '.venv' then
            venv_name = project_name
        else
            venv_name = venv_dir_name
        end
    end

    local python_version = nil

    local py_version_string = my_utils.run_shell_cmd(python_path .. ' --version')

    if py_version_string ~= nil then
        _, _, major, minor, patch = string.find(py_version_string, "%s*Python%s*(%d+).(%d+).(%d+)")

        if minor == nil then
            python_version = major
        else
            python_version = major .. '.' .. minor
        end
    end

    return {
        name = venv_name,
        venv_manager_name = my_utils.get(venv_manager, "name"),
        python_path = python_path,
        python_version = python_version,
    }
end

function M.get_python_venv(bufnr, opts)
    local opts = plenary_tbl.apply_defaults(opts,
        { disable_notifications = false, fallback_to_system_python = false, venv_manager = nil })

    if bufnr == nil then
        bufnr = vim.api.nvim_get_current_buf()
    end

    if venvs_per_buf_cache[bufnr] == nil then
        venvs_per_buf_cache[bufnr] = get_python_path_no_cache(bufnr, opts)
    end

    return venvs_per_buf_cache[bufnr]
end

local function pyright_auto_set_python_venv(client, bufnr)
    local venv = M.get_python_venv(bufnr, { disable_notifications = false, fallback_to_system_python = true })

    client.config.settings.python.pythonPath = venv.python_path
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
end

function M.on_attach(client, bufnr)
    if client.name ~= "pyright" then
        return
    end

    pyright_auto_set_python_venv(client, bufnr)

    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("AutoSetPythonVenv", { clear = false }),
        buffer = bufnr,
        callback = function(event)
            pyright_auto_set_python_venv(client, bufnr)
        end
    })
end

return M
