return {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    -- TODO: Migrate treesitter's text objects to this
    opts = {
        custom_textobjects = {
            ["i"] = require('mini.extra').gen_ai_spec.indent(),
        }
    },
}
