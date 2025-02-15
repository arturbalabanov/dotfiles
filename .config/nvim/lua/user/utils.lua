local plenary_tbl = require("plenary.tbl")
local plenary_functional = require("plenary.functional")

local M = {}

local unpack = unpack or table.unpack

M.error_fmt = function(msg_fmt, ...)
    return error(string.format(msg_fmt, ...))
end

-- TODO: Maybe autodetect the caller function name, see the implementation of opt_require
M.usage_error = function(func_name)
    return function(msg_fmt, ...)
        local msg = string.format(msg_fmt, ...)
        return M.error_fmt("%s usage error: %s", func_name, msg)
    end
end

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

M.keymap = function(mode, input, output, opts)
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

    return M.keymap("t", input, function()
        if M.get_zsh_vim_mode() ~= zsh_vim_mode then
            return input
        end

        return output()
    end, opts)
end

M.nkeymap = plenary_functional.partial(M.keymap, "n")
M.ikeymap = plenary_functional.partial(M.keymap, "i")
M.vkeymap = plenary_functional.partial(M.keymap, "v")
M.xkeymap = plenary_functional.partial(M.keymap, "x")
M.tkeymap = plenary_functional.partial(M.keymap, "t")

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

function M.show_in_split(str, opts)
    local opts_with_defaults = plenary_tbl.apply_defaults(opts, { filetype = "text", split_cmd = "split" })

    local buf = vim.api.nvim_create_buf(false, true) -- args: listed, scratch

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(str, '\n', { plain = true }))
    vim.api.nvim_buf_set_option(buf, "filetype", opts_with_defaults.filetype)
    vim.api.nvim_buf_set_option(buf, "modified", false)

    vim.cmd(opts_with_defaults.split_cmd)
    vim.api.nvim_win_set_buf(0, buf)
end

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
        local error_msg = module
        local caller_stack_level = 2

        -- `n´	selects fields name and namewhat
        -- `f´	selects field func
        -- `S´	selects fields source, short_src, what, and linedefined
        -- `l´	selects field currentline
        -- `u´	selects field nup
        --
        -- ref: https://www.lua.org/pil/23.1.html

        local caller_info = debug.getinfo(caller_stack_level, "Slf")

        local title = string.format(
            "opt_require: Failed loading `%s`, skipping",
            module_path
        )

        local detail_lines = {
            "# Error",
            "",
            error_msg,
            "",
            "# Extra Info",
            "",
            string.format("Module Path: `%s`", module_path),
            string.format("Caller File: `%s`", caller_info.source),
            string.format("Caller Line: %d", caller_info.currentline),
            string.format("Caller Function: %s", vim.inspect(caller_info.func)),
            "",
        }

        M.markdown_notify(title, detail_lines, "warn")
        return nil
    end

    return module
end

function M.timeout(ms, fn)
    local timer = vim.loop.new_timer()

    return function(...)
        local argv = { ... }
        timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
        end)
    end
end

function M.markdown_notify(title, msg_lines, level, opts)
    -- TODO: Utilise render-markdown.nvim

    level = level or "info"
    opts = opts or {}

    local on_open = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end

    local message

    if type(msg_lines) == "string" then
        message = msg_lines
    elseif type(msg_lines) == "table" then
        message = table.concat(msg_lines, "\n")
    else
        message = vim.inspect(message)
    end

    opts.title = title
    opts.on_open = on_open

    vim.notify(message, level, opts)
end

-- TODO: Extract into submodule
M.kitty = {}
M.kitty.send_cmd = function(cmd, ...)
    local args = { ... }
    local kitty_listen_socket = vim.fn.expand("$KITTY_LISTEN_ON")
    local kitty_cmd = string.format("kitty @ --to %s %s -- %s", kitty_listen_socket, cmd, table.concat(args, " "))

    M.run_shell_cmd(kitty_cmd)
end

M.md = {}
M.markdown = M.md

M.md.to_list = function(tbl, opts)
    if not vim.tbl_islist(tbl) then
        error("argument tbl is not a list table")
    end

    local default_opts = {
        value_format = "%s",
    }
    opts = plenary_tbl.apply_defaults(opts, default_opts)

    local lines = {}

    for _, value in pairs(tbl) do
        local formatted_value = string.format(opts.value_format, value)
        local list_item = string.format("* %s", formatted_value)
        table.insert(lines, list_item)
    end

    return table.concat(lines, "\n")
end

return M
