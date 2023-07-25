local my_utils = require("user.utils")

local scroll_eof = my_utils.opt_require('scrollEOF')
if scroll_eof == nil then
    return
end

-- ref: https://github.com/Aasim-A/scrollEOF.nvim

scroll_eof.setup({
    -- The pattern used for the internal autocmd to determine
    -- where to run scrollEOF. See https://neovim.io/doc/user/autocmd.html#autocmd-pattern
    pattern = '*',
    -- Whether or not scrollEOF should be enabled in insert mode
    insert_mode = false,
    -- List of filetypes to disable scrollEOF for.
    disabled_filetypes = {},
    -- List of modes to disable scrollEOF for. see https://neovim.io/doc/user/builtin.html#mode() for available modes.
    disabled_modes = {},
})
