local Path = require("plenary.path")
local plenary_tbl = require("plenary.tbl")

local M = {}

local function run_shell_cmd(cmd, opts)
    opts = plenary_tbl.apply_defaults(opts, { disable_notifications = true })
    return require("utils.shell").run_cmd(cmd, opts)
end

local function file_present_in_proj_checker(file_name)
    return function(project_root)
        local match = vim.fn.glob(Path:new(project_root):joinpath(file_name):expand())
        return match ~= ''
    end
end

local function pipenv_get_python_path(project_root)
    local output = run_shell_cmd('pipenv --venv', { cwd = project_root })

    if output == nil then
        return nil
    end

    local output_lines = vim.split(output, '\n')
    local venv_path = output_lines[#output_lines]

    return Path:new(venv_path):joinpath('bin', 'python'):expand()
end

local function pdm_get_python_path(project_root)
    return run_shell_cmd('pdm venv --python in-project', { cwd = project_root })
end

local function poetry_get_python_path(project_root)
    local venv_path = run_shell_cmd('poetry env info -p', { cwd = project_root })

    if venv_path == nil then
        return nil
    end

    return Path:new(venv_path):joinpath('bin', 'python'):expand()
end

local function uv_get_python_path(project_root)
    return run_shell_cmd('uv python find', { cwd = project_root })
end

M.default_venv_managers = {
    {
        name = 'uv',
        executable_name = 'uv',
        is_managing_proj_func = file_present_in_proj_checker('uv.lock'),
        get_python_path_func = uv_get_python_path,
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
    {
        name = "Pipenv",
        executable_name = 'pipenv',
        is_managing_proj_func = file_present_in_proj_checker('Pipfile.lock'),
        get_python_path_func = pipenv_get_python_path,
    },
    -- TODO: Add support for hatch
    -- TODO: Add support for the buit in python venv manager (python -m venv)
    -- TODO: Add support for virtualenvwrapper
    -- TODO: Add support for conda

}

M.enabled_venv_managers = {}

for _, venv_manager in pairs(M.default_venv_managers) do
    if require("utils.shell").executable_exists(venv_manager.executable_name) then
        table.insert(M.enabled_venv_managers, venv_manager)
    end
end

function M.get_venv_manager(project_root)
    for _, venv_manager in pairs(M.enabled_venv_managers) do
        if venv_manager.is_managing_proj_func(project_root) then
            return venv_manager
        end
    end

    return nil
end

return M
