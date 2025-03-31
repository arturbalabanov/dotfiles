local M = {}

local partial = function(fun, ...)
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

-- TODO: Set a warning if the keymap's desc is not set
M.set = function(mode, input, output, opts)
    local usage_error = require("utils").usage_error("utils.keymap.set")

    local default_keymap_opts = { silent = true, remap = false }
    local opts_with_defaults = require("utils").apply_defaults(opts, default_keymap_opts)

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

        output = partial(func, unpack(args))
    end

    return vim.keymap.set(mode, input, output, opts_with_defaults)
end

local function set_terminal_mode(zsh_vim_mode, input, output, opts)
    local usage_error = require("utils").usage_error("utils.keymap.set_terminal_mode")
    local tkmeymap_func_name

    if zsh_vim_mode == "insert" then
        tkmeymap_func_name = "set_ti"
    elseif zsh_vim_mode == "normal" then
        tkmeymap_func_name = "set_tn"
    elseif zsh_vim_mode == "visual" then
        tkmeymap_func_name = "set_tv"
    else
        usage_error("invalid zsh_vim_mode: " .. zsh_vim_mode)
    end


    if type(output) ~= "function" then
        usage_error(tkmeymap_func_name .. ' only supports functions as arguments for now')
    end

    return M.set("t", input, function()
        if require("utils.shell").get_zsh_vim_mode() ~= zsh_vim_mode then
            return input
        end

        return output()
    end, opts)
end

M.set_n = partial(M.set, "n")
M.set_i = partial(M.set, "i")
M.set_v = partial(M.set, "v")
M.set_x = partial(M.set, "x")
M.set_t = partial(M.set, "t")

M.set_ti = partial(set_terminal_mode, "insert")
M.set_tn = partial(set_terminal_mode, "normal")
M.set_tv = partial(set_terminal_mode, "visual")

return M
