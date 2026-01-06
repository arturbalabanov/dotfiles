local M = {}

-- TODO: replace with require("plenary.tbl").apply_defaults ONLY IF CAN LOAD THAT MODULE
M.apply_defaults = function(original, defaults)
    if original == nil then
        original = {}
    end

    original = vim.deepcopy(original)

    for k, v in pairs(defaults) do
        if original[k] == nil then
            original[k] = v
        end
    end

    return original
end

-- TODO: replace with plenary partial function ONLY IF CAN LOAD THAT MODULE
M.partial = function(fun, ...)
    local function bind_n(fn, n, a, ...)
        if n == 0 then
            return fn
        end
        return bind_n(function(...)
            return fn(a, ...)
        end, n - 1, ...)
    end
    return bind_n(fun, select("#", ...), ...)
end

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

-- TODO: use plenary equivalent if available
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

function M.show_in_split(str, opts)
    local opts_with_defaults = M.apply_defaults(opts, { filetype = "text", split_cmd = "split" })

    local buf = vim.api.nvim_create_buf(false, true) -- args: listed, scratch

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(str, "\n", { plain = true }))
    vim.api.nvim_buf_set_option(buf, "filetype", opts_with_defaults.filetype)
    vim.api.nvim_buf_set_option(buf, "modified", false)

    vim.cmd(opts_with_defaults.split_cmd)
    vim.api.nvim_win_set_buf(0, buf)
end

function M.warn_with_caller_info(title, opts)
    opts = M.apply_defaults(opts, { stack_level = 2, notification_timeout_ms = 10 * 1000 })

    -- `n´	selects fields name and namewhat
    -- `f´	selects field func
    -- `S´	selects fields source, short_src, what, and linedefined
    -- `l´	selects field currentline
    -- `u´	selects field nup
    --
    -- ref: https://www.lua.org/pil/23.1.html
    local caller_info = debug.getinfo(opts.stack_level, "Slf")

    local detail_lines = {
        "### Caller Info",
        "",
        string.format("File: `%s`", caller_info.source),
        string.format("Line: %d", caller_info.currentline),
        string.format("Function: %s", vim.inspect(caller_info.func)),
        "",
    }

    require("utils.markdown").notify(title, detail_lines, "warn", { timeout = opts.notification_timeout_ms })
end

-- TODO: use warn_with_caller_info internally
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

        local title = string.format("opt_require: Failed loading `%s`, skipping", module_path)

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

        require("utils.markdown").notify(title, detail_lines, "warn")
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

M.move_jump_to_new_tab = function(jump_func)
    local usage_error = M.usage_error("move_jump_to_new_tab")

    if type(jump_func) ~= "function" then
        usage_error("jump_func must be a function")
    end

    local orig_winnr = vim.api.nvim_get_current_win()
    local orig_bufnr = vim.api.nvim_get_current_buf()

    jump_func()

    local post_jump_bufnr = vim.api.nvim_get_current_buf()

    if orig_bufnr == post_jump_bufnr then
        return
    end

    vim.cmd("tab split")
    vim.api.nvim_win_set_buf(orig_winnr, orig_bufnr)
end

function M.get_var_or_default(var_name, default_value, opts)
    -- API modeled after vim.api.nvim_get_option_value
    opts = opts or { scope = "global" }

    if opts.win == nil and opts.buf == nil and opts.scope == "local" then
        error("get_var_or_default: win or buf option is required for local scope")
    end

    if opts.win ~= nil and opts.buf ~= nil then
        error("get_var_or_default: ambiguous options win and buf, please specify only one")
    end

    local get_var_func
    if opts.win ~= nil then
        if opts.scope == "global" then
            error("get_var_or_default: win option is not supported for global scope")
        end

        get_var_func = function(name)
            return vim.api.nvim_win_get_var(opts.win, name)
        end
    elseif opts.buf ~= nil then
        if opts.scope ~= "local" then
            error("get_var_or_default: buf option is only supported for local scope")
        end

        get_var_func = function(name)
            return vim.api.nvim_buf_get_var(opts.buf, name)
        end
    elseif opts.scope == "global" then
        get_var_func = vim.api.nvim_get_var
    else
        error("get_var_or_default: invalid opts: " .. vim.inspect(opts))
    end

    local found, value = pcall(get_var_func, var_name)

    if not found then
        return default_value
    end

    return value
end

return M
