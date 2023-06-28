require('mini.pairs').setup()
require('mini.cursorword').setup()
require('mini.surround').setup({
    mappings = {
        add = 'sa',
        replace = 'sc',
    }
})
local function get_comment_keymap()
    if vim.g.neovide then
        return "<C-/>"
    end

    if vim.env.ZELLIJ ~= nil then
        -- NOTE: In some terminals (or in zellij) C-/ is triggered by C-_
        return "<C-_>"
    end

    return "<C-/>"
end

require('mini.comment').setup({
    mappings = {
        comment = get_comment_keymap(),
        comment_line = get_comment_keymap(),
    }
})
