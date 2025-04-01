local M = {}

local keymap = vim.keymap.set

local function set_default_opts(opts)
    local opts_with_defaults = opts or {}

    if opts_with_defaults.silent == nil then
        opts_with_defaults.silent = true
    end

    return opts_with_defaults
end

function M.nkeymap(input, output, opts)
    return keymap("n", input, output, set_default_opts(opts))
end

function M.ikeymap(input, output, opts)
    return keymap("i", input, output, set_default_opts(opts))
end

function M.vkeymap(input, output, opts)
    return keymap("v", input, output, set_default_opts(opts))
end

return M
