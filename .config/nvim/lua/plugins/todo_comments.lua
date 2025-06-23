return {
    "folke/todo-comments.nvim",
    opts = {
        merge_keywords = true, -- custom keywords (bellow) will be merged with the defaults
        keywords = {
            IMPORTANT = { icon = " ", color = "error", alt = { "IMP" } },
        },
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
            multiline = true,         -- enable multine todo comments
            multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
            multiline_context = 10,   -- extra lines that will be re-evaluated when changing a line
            before = "",              -- "fg" or "bg" or empty
            keyword = "wide_bg",      -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty.
            -- (wide and wide_bg is the same as bg, but will also highlight
            -- surrounding characters, wide_fg acts accordingly but with fg)
            after = "fg",                    -- "fg" or "bg" or empty
            pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
            comments_only = true,            -- uses treesitter to match keywords in comments only
            max_line_len = 400,              -- ignore lines longer than this
            exclude = {},                    -- list of file types to exclude highlighting
        },
    },
    event = "VeryLazy",
    keys = {
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
    },
}

-- TODO: This is a testing comment

-- FIX:  This is a testing comment

-- FIXME: another tesitng comment

-- BUG: This is a testing comment

-- IMPORTANT: This is a testing comment

-- IMP: This is a testing comment

-- HACK: This is a testing comment

-- PERF: This is a testing comment

-- NOTE: This is a testing comment

-- WARN: This is a testing comment

-- WARNING: This is a testing comment

-- XXX: This is a testing comment

-- NONE: This is a testing comment

-- none: this is a testing comment

-- todo: this is a testing comment
