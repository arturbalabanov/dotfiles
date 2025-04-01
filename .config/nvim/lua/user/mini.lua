require('mini.pairs').setup()
require('mini.cursorword').setup()
require('mini.surround').setup({
    mappings = {
        add = 'sa'
    }
})
require('mini.splitjoin').setup({
    mappings = {
        toggle = 'sj'
    }
})
require('mini.comment').setup({
    mappings = {
        -- C-_ actually means C-/
        comment = '<C-_>',
        comment_line = '<C-_>',
    }
})
