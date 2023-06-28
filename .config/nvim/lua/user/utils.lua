local plenary_tbl = require("plenary.tbl")
local plenary_functional = require("plenary.functional")

local M = {}

local unpack = unpack or table.unpack

M.executable_exists = function(executable)
    return vim.fn.executable(executable) == 1
    -- local status_ok, _ = pcall(vim.fn.system, "type " .. executable)
    --
    -- return status_ok and (vim.v.shell_error == 0)
end

M.run_shell_cmd = function(cmd, opts)
    local opts = plenary_tbl.apply_defaults(opts, { cwd = nil, show_error = true, disable_notifications = false })

    if opts.cwd ~= nil then
        vim.cmd.lcd(opts.cwd)
    end

    local status_ok, stdout = pcall(vim.fn.system, cmd)

    stdout = vim.fn.trim(stdout or "")

    if opts.cwd ~= nil then
        vim.cmd.lcd("-")
    end

    if not status_ok or (vim.v.shell_error ~= 0) then
        if opts.show_error then
            local descr_lines = {
                "command: " .. vim.inspect(cmd),
                "shell_error: " .. vim.inspect(vim.v.shell_error),
                "stdout: " .. stdout,
            }

            if opts.cwd ~= nil then
                table.insert(descr_lines, "cwd: " .. opts.cwd)
            end

            if not opts.disable_notifications then
                vim.notify(table.concat(descr_lines, '\n'), "error", {
                    title = "Command execution failed"
                })
            end
        end

        return nil
    end

    return vim.fn.trim(stdout)

    -- local tmpfile = os.tmpname()
    --
    -- local full_cmd = cmd .. ' > ' .. tmpfile
    -- local child_process = false
    -- if opts.cwd ~= nil then
    --     full_cmd = '(' .. "cd " .. opts.cwd .. "; " .. full_cmd .. ")"
    --     child_process = true
    -- end
    --
    -- -- ref: https://stackoverflow.com/a/30954739
    -- local exit_code = os.execute(full_cmd) / 256
    -- if child_process and exit_code > 128 then
    --     exit_code = exit_code - 128
    -- end
    --
    -- if exit_code ~= 0 then
    --     return nil
    -- end
    --
    -- local stdout_file = io.open(tmpfile)
    -- local stdout = stdout_file:read("*all")
    --
    -- stdout_file:close()
    --
    -- return vim.fn.trim(stdout)
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

M.usage_error = function(func_name)
    return function(msg)
        return error(func_name .. " usage error: " .. msg)
    end
end

local function keymap(mode, input, output, opts)
    local usage_error = M.usage_error("keymap")

    local default_keymap_opts = { silent = true, remap = false }
    local opts_with_defaults = plenary_tbl.apply_defaults(opts, default_keymap_opts)

    if output == nil then
        usage_error("output is nil")
    end

    if type(output) == "table" then
        if #output == 0 then
            usage_error("output is an empty table")
        end

        local func = table.remove(output, 1)

        if type(func) ~= "function" then
            usage_error("when output is a table, the first arg must be a function")
        end

        local args = output or {}

        output = plenary_functional.partial(func, unpack(args))
    end

    return vim.keymap.set(mode, input, output, opts_with_defaults)
end

local function t_mode_keymap(zsh_vim_mode, input, output, opts)
    local tkmeymap_func_name

    if zsh_vim_mode == "insert" then
        tkmeymap_func_name = "tikeymap"
    elseif zsh_vim_mode == "normal" then
        tkmeymap_func_name = "tnkeymap"
    elseif zsh_vim_mode == "visual" then
        tkmeymap_func_name = "tvkeymap"
    else
        error("invalid zsh_vim_mode for t_mode_keymap: " .. zsh_vim_mode)
    end


    if type(output) ~= "function" then
        error(tkmeymap_func_name .. ' only supports functions as arguments for now')
    end

    return keymap("t", input, function()
        if M.get_zsh_vim_mode() ~= zsh_vim_mode then
            return input
        end

        return output()
    end, opts)
end

M.nkeymap = plenary_functional.partial(keymap, "n")
M.ikeymap = plenary_functional.partial(keymap, "i")
M.vkeymap = plenary_functional.partial(keymap, "v")
M.xkeymap = plenary_functional.partial(keymap, "x")
M.tkeymap = plenary_functional.partial(keymap, "t")

M.tikeymap = plenary_functional.partial(t_mode_keymap, "insert")
M.tnkeymap = plenary_functional.partial(t_mode_keymap, "normal")
M.tvkeymap = plenary_functional.partial(t_mode_keymap, "visual")


function M.simple_autocmd(event_name, callback, opts)
    local opts = plenary_tbl.apply_defaults(opts, { clear = true })
    local augroup = vim.api.nvim_create_augroup("User", { clear = opts.clear })

    vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        callback = callback,
        pattern = opts.pattern,
    })
end

function M.get(tbl, ...)
    local path = { ... }

    if tbl == nil then
        return nil
    end

    local next_key = table.remove(path, 1)
    local value = tbl[next_key]

    if #path == 0 then
        return value
    end

    if type(value) ~= "table" then
        return nil
    end

    return M.get(value, unpack(path))
end

function M.simple_notify(msg, level)
    if level == nil then
        level = "info"
    end

    if type(msg) ~= "string" then
        msg = vim.inspect(msg)
    end

    vim.notify(msg, level, { render = "compact" })
end

M.partial = plenary_functional.partial


local NO_VALUE = '__NO_VALUE_SENTINEL__'

local cache_vault = {}

M.get_or_update_cache = function(namespace, key, get_value_func, opts)
    opts = plenary_tbl.apply_defaults(opts, { save_nil_values = true })

    local vault = cache_vault[namespace]

    if vault == nil then
        vault = {}
        cache_vault[namespace] = vault
    end

    local cached_value = vault[key]

    if cached_value == NO_VALUE then
        -- get_value_func returned nil last time it was called
        return nil
    end

    if cached_value ~= nil then
        return cached_value
    end

    local new_value = get_value_func(key)

    if new_value == nil and opts.save_nil_values then
        vault[key] = NO_VALUE
    else
        vault[key] = new_value
    end

    return new_value
end

function M.opt_require(module_path)
    local status_ok, module = pcall(require, module_path)
    if not status_ok then
        local caller_stack_level = 2

        -- `n´	selects fields name and namewhat
        -- `f´	selects field func
        -- `S´	selects fields source, short_src, what, and linedefined
        -- `l´	selects field currentline
        -- `u´	selects field nup
        --
        -- ref: https://www.lua.org/pil/23.1.html

        local caller_info = debug.getinfo(caller_stack_level, "Sl")

        local msg = string.format(
            "Failed loading `%s` from %s:%d, skipping",
            module_path,
            caller_info.short_src,
            caller_info.currentline
        )

        M.simple_notify(msg, "warn")
        return nil
    end

    return module
end

return M
