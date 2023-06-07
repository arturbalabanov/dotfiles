local M = {}

-- TODO: Replace with plantery
---The file system path separator for the current platform.
M.path_separator = "/"

M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1

if M.is_windows == true then
    M.path_separator = "\\"
end

-- TODO: Replace with plenary
---Split string into a table of strings using a separator.
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
function M.split(inputString, sep)
    local fields = {}

    local pattern = string.format("([^%s]+)", sep)
    local _ = string.gsub(inputString, pattern, function(c)
        fields[#fields + 1] = c
    end)

    return fields
end

-- TODO: Replace with plenary
---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
function M.path_join(...)
    local args = { ... }
    if #args == 0 then
        return ""
    end

    local all_parts = {}
    if type(args[1]) == "string" and args[1]:sub(1, 1) == M.path_separator then
        all_parts[1] = ""
    end

    for _, arg in ipairs(args) do
        local arg_parts = M.split(arg, M.path_separator)
        vim.list_extend(all_parts, arg_parts)
    end
    return table.concat(all_parts, M.path_separator)
end

local keymap = vim.keymap.set

-- TODO: replace with plenary.tbl.apply_defaults
local function opts_with_defaults(opts, defaults)
    local opts_with_defaults = opts or {}

    for opt_name, default_val in pairs(defaults) do
        if opts_with_defaults[opt_name] == nil then
            opts_with_defaults[opt_name] = default_val
        end
    end

    return opts_with_defaults
end


M.run_shell_cmd = function(cmd)
    local status_ok, output = pcall(vim.fn.system, cmd)

    if not status_ok or vim.v.shell_error ~= 0 then
        return nil
    end

    return vim.fn.trim(output)
end

M.get_process_running_in_term = function(buffer)
    if buffer == nil then
        buffer = vim.fn.bufnr()
    end

    local status_ok, terminal_pid = pcall(vim.api.nvim_buf_get_var, buffer, 'terminal_job_pid')

    if not status_ok or terminal_pid == nil then
        -- Buffer is not a terminal
        return nil
    end

    local running_process_cmd = (
        "ps -o state= -o comm= -p " .. terminal_pid
        .. " | grep -iE '^[^TXZ ]+'"
        .. " | awk '{ print $2 }'"
    )

    return M.run_shell_cmd(running_process_cmd)
end

M.is_zsh_running_in_tem = function(buffer)
    local process_name = M.get_process_running_in_term(buffer)

    if process_name == nil then
        return false
    end

    local process_path_parts = vim.fn.split(process_name, '/')
    local parts_len = select("#", process_path_parts)

    return process_path_parts[parts_len] == 'zsh'
end

M.get_zsh_vim_mode = function(buffer)
    if buffer == nil then
        buffer = vim.fn.bufnr()
    end

    local status_ok, terminal_pid = pcall(vim.api.nvim_buf_get_var, buffer, 'terminal_job_pid')

    if not status_ok or terminal_pid == nil then
        -- Buffer is not a terminal
        return nil
    end

    return M.run_shell_cmd("cat /tmp/zsh_vim_mode_" .. terminal_pid)
end

local default_keymap_opts = { silent = true, remap = false }

function M.tkeymap(input, output, opts)
    return keymap("t", input, output, opts_with_defaults(opts, default_keymap_opts))
end

function M.tikeymap(input, output, opts)
    if type(output) ~= "function" then
        error('tikeymap only supports functions as arguments for now')
    end

    return keymap("t", input, function()
        if M.get_zsh_vim_mode() ~= "insert" then
            return input
        end

        return output()
    end, opts_with_defaults(opts, default_keymap_opts))
end

function M.tnkeymap(input, output, opts)
    if type(output) ~= "function" then
        error("tnkeymap doesn't support non-functions as arguments for now")
    end

    local new_opts = opts_with_defaults(opts, default_keymap_opts)

    return keymap("t", input, function()
        if M.get_zsh_vim_mode() ~= "normal" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input, true, false, true), "t", true)
            return
        end

        return output()
    end, new_opts)
end

function M.tvkeymap(input, output, opts)
    if type(output) ~= "function" then
        error('tvkeymap only supports functions as arguments for now')
    end

    return keymap("t", input, function()
        if M.get_zsh_vim_mode() ~= "visual" then
            return input
        end

        output()
    end, opts_with_defaults(opts, default_keymap_opts))
end

function M.nkeymap(input, output, opts)
    return keymap("n", input, output, opts_with_defaults(opts, default_keymap_opts))
end

function M.ikeymap(input, output, opts)
    return keymap("i", input, output, opts_with_defaults(opts, default_keymap_opts))
end

function M.vkeymap(input, output, opts)
    return keymap("v", input, output, opts_with_defaults(opts, default_keymap_opts))
end

function M.simple_autocmd(event_name, callback, opts)
    local opts = opts_with_defaults(opts, { clear = true })
    local augroup = vim.api.nvim_create_augroup("User", { clear = opts.clear })

    vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        callback = callback,
        pattern = opts.pattern,
    })
end

function M.get_python_path(workspace_dir)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return M.path_join(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end

    -- Find and use virtualenv via various venv tools

    -- pdm:
    local match = vim.fn.glob(M.path_join(workspace_dir, 'pdm.lock'))
    if match ~= '' then
        return vim.fn.trim(vim.fn.system('pdm venv --python in-project'))
    end

    -- poetry:
    local match = vim.fn.glob(M.path_join(workspace_dir, 'poetry.lock'))
    if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
        return M.path_join(venv, 'bin', 'python')
    end

    -- pipenv:
    local match = vim.fn.glob(M.path_join(workspace_dir, 'Pipfile.lock'))
    if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('pipenv --venv'))
        return M.path_join(venv, 'bin', 'python')
    end

    -- Fallback to system Python.
    return exepath('python3') or exepath('python') or 'python'
end

-- TODO: Replace with plenary
-- A simple function call taking into account positional and table args.
--
-- Example:
--
--     apply(function(a, b, c, d)
--         print("last array argument is unpacked")
--         assert(a == 1)
--         assert(b == 2)
--         assert(c == 3)
--         assert(d == 4)
--     end, 1, 2, {3, 4})
--
-- ref: https://github.com/Gozala/functional-lua/blob/master/apply.lua

function M.apply(lambda, ...)
    local params = table.pack(...)
    local count = params.n
    local offest = count - 1
    local packed = params[count]

    if (type(packed) == "table") then
        params[count] = nil
        for key, value in pairs(packed) do
            if (type(key) == "number") then
                local index = key
                count = offest + index
                params[count] = value
            end
        end
    end

    return lambda(unpack(params, 1, count))
end

-- TODO: Replace with plenary
-- refs:
-- * https://github.com/Gozala/functional-lua/blob/master/partial.lua
function M.partial(fn, ...)
    local curried = table.pack(...)
    local offset = curried.n

    return function(...)
        local params = { unpack(curried, 1, offset) }

        params[offset + 1] = table.pack(...)
        return M.apply(fn, unpack(params, 1, offset + 1))
    end
end

return M
