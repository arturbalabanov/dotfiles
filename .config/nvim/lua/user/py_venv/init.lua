local status_ok, project_nvim = pcall(require, "project_nvim.project")
if not status_ok then
    return
end

local Path = require("plenary.path")
local plenary_tbl = require("plenary.tbl")

local my_utils = require("user.utils")

local venv_managers = require("user.py_venv.venv_managers")

local M = {}

function M.get_project_venv_python_path(project_root, opts)
    opts = plenary_tbl.apply_defaults(opts, { disable_notifications = false, venv_manager = nil })

    return my_utils.get_or_update_cache('get_project_venv_python_path', project_root, function()
        if vim.env.VIRTUAL_ENV then
            if not opts.disable_notifications then
                my_utils.simple_notify("Using activated venv" .. vim.env.VIRTUAL_ENV, "info")
            end

            return Path:new(vim.env.VIRTUAL_ENV):joinpath('bin', 'python'):expand()
        end

        local venv_manager = opts.venv_manager

        if venv_manager == nil then
            venv_manager = venv_managers.get_venv_manager(project_root)

            if venv_manager == nil then
                return nil
            end
        end

        return venv_manager.get_python_path_func(project_root)
    end)
end

local function get_venv_name(python_path, project_root)
    if python_path == nil then
        return nil
    end

    -- :h is the parent
    -- :t is the last component
    -- The pythonpath is <venv-path>/bin/python

    local venv_dir_path = vim.fn.fnamemodify(python_path, ":h:h")
    local venv_dir_name = vim.fn.fnamemodify(venv_dir_path, ":t")
    local project_name = vim.fn.fnamemodify(project_root, ':t')

    -- TODO: If the venv manager supports getting the venv name, use that instead

    if venv_dir_name == '.venv' then
        return project_name
    end

    return venv_dir_name
end

local function get_python_version(python_path, opts)
    opts = plenary_tbl.apply_defaults(opts, { disable_notifications = false, full_version = false })

    local py_version_output = my_utils.run_shell_cmd(python_path .. ' --version',
        { disable_notifications = opts.disable_notifications })

    if py_version_output == nil then
        return nil
    end

    local _, _, py_version_string = string.find(py_version_output, "%s*Python%s*(.+)%s*$")

    if opts.full_version then
        return py_version_string
    end

    local _, _, major, minor = string.find(py_version_string, "(%d+).(%d+)")

    if minor == nil then
        return major
    end

    return major .. '.' .. minor
end

local function get_python_venv_no_cache(opts)
    opts = plenary_tbl.apply_defaults(opts,
        { disable_notifications = false, fallback_to_system_python = false, venv_manager = nil, full_version = false })

    local project_root = project_nvim.find_pattern_root()

    if opts.venv_manager == nil then
        opts.venv_manager = venv_managers.get_venv_manager(project_root)

        if opts.venv_manager == nil then
            if not opts.fallback_to_system_python then
                if not opts.disable_notifications then
                    local msg = "No venv was found for " .. project_root .. " and fallback to system python is disabled"
                    my_utils.simple_notify(msg, "error")
                end

                return nil
            end
        end
    end

    local venv_manager = opts.venv_manager

    local venv_python_path = M.get_project_venv_python_path(project_root, opts)
    local python_path = venv_python_path

    if python_path == nil then
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

        python_path = vim.loop.exepath('python3') or vim.loop.exepath('python') or 'python'
    end

    local venv_bin_path = nil

    if venv_python_path ~= nil then
        venv_bin_path = vim.fn.fnamemodify(venv_python_path, ':h')
    end

    local python_version = get_python_version(python_path,
        { disable_notifications = opts.disable_notifications, full_version = opts.full_version })

    local pyproject_toml = Path:new(project_root):joinpath('pyproject.toml'):expand()

    return {
        name = get_venv_name(venv_python_path, project_root),
        bin_path = venv_bin_path,
        python_path = python_path,
        python_version = python_version,
        pyproject_toml = pyproject_toml,
        venv_manager_name = my_utils.get(venv_manager, "name"),
    }
end

function M.get_python_venv(bufnr, opts)
    opts = plenary_tbl.apply_defaults(opts,
        { disable_notifications = false, fallback_to_system_python = false, venv_manager = nil, full_version = false })

    if bufnr == nil then
        bufnr = vim.api.nvim_get_current_buf()
    end

    return my_utils.get_or_update_cache('get_python_venv', bufnr, function() return get_python_venv_no_cache(opts) end)
end

function M.buf_local_command_path(command, bufnr)
    local venv = M.get_python_venv(bufnr, { disable_notifications = true })

    if venv == nil then
        return command
    end

    return Path:new(venv.bin_path):joinpath(command):expand()
end

local function pyright_set_venv(client, venv)
    client.config.settings.python.pythonPath = venv.python_path
    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
end

local set_venv_per_client = {
    pyright = pyright_set_venv,
}

function M.on_attach(client, bufnr)
    local norm_client_name = client.name:gsub('%-', '_')
    local set_venv = set_venv_per_client[norm_client_name]

    if set_venv == nil then
        return
    end

    local var_name = "py_venv_info"

    local found, saved_venv = pcall(vim.api.nvim_buf_get_var, bufnr, var_name)
    local venv = M.get_python_venv(bufnr, { disable_notifications = false, fallback_to_system_python = true })

    if not found or saved_venv ~= venv then
        vim.api.nvim_buf_set_var(bufnr, var_name, venv)
        set_venv(client, venv)
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("AutoSetPythonVenv__" .. norm_client_name, { clear = false }),
        buffer = bufnr,
        callback = function(event)
            found, saved_venv = pcall(vim.api.nvim_buf_get_var, bufnr, var_name)
            venv = M.get_python_venv(bufnr, { disable_notifications = false, fallback_to_system_python = true })

            if not found or saved_venv ~= venv then
                vim.api.nvim_buf_set_var(bufnr, var_name, venv)
                set_venv(client, venv)
            end
        end
    })
end

return M
