require('mini.pairs').setup()
require('mini.cursorword').setup()
require('mini.surround').setup({
    mappings = {
        add = 'sa',
        replace = 'sc',
    }
})
require('mini.splitjoin').setup({
    mappings = {
        toggle = 'sj',
    }
})


local comment_keymap = "<C-/>"

if os.getenv("ZELLIJ") ~= nil then
    -- NOTE: In some terminals (or in zellij) C-/ is triggered by C-_
    comment_keymap = "<C-_>"
end


require('mini.comment').setup({
    mappings = {
        comment = comment_keymap,
        comment_line = comment_keymap,
    }
})
