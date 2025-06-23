return {
    "kwkarlwang/bufjump.nvim",
    opts = {
        -- disable the default keymaps
        forward_key = nil,
        backward_key = nil,
        forward_same_buf_key = nil,
        backward_same_buf_key = nil,
    },
    keys = {
        { "[j", function() require('bufjump').backward() end,          desc = "jumplist: previous buffer" },
        { "]j", function() require('bufjump').forward() end,           desc = "jumplist: next buffer" },
        { "[J", function() require('bufjump').backward_same_buf() end, desc = "jumplist: previous item in this buffer" },
        { "]J", function() require('bufjump').forward_same_buf() end,  desc = "jumplist: next item in this buffer" },
    },
}
