local M = {}

local keymap = vim.keymap.set

local function opts_with_defaults(opts, defaults)
    local opts_with_defaults = opts or {}

    for opt_name, default_val in pairs(defaults) do
        if opts_with_defaults[opt_name] == nil then
            opts_with_defaults[opt_name] = default_val
        end
    end

    return opts_with_defaults
end

function M.nkeymap(input, output, opts)
    return keymap("n", input, output, opts_with_defaults(opts, {silent = true}))
end

function M.ikeymap(input, output, opts)
    return keymap("i", input, output, opts_with_defaults(opts, {silent = true}))
end

function M.vkeymap(input, output, opts)
    return keymap("v", input, output, opts_with_defaults(opts, {silent = true}))
end


function M.simple_autocmd(event_name, callback, opts)
    local opts = opts_with_defaults(opts, {clear = false})
    local augroup = vim.api.nvim_create_augroup("User", { clear = opts.clear })

    vim.api.nvim_create_autocmd(event_name, {
        group = augroup,
        callback = callback
    })
end

return M
