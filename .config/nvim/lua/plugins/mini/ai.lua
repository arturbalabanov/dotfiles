return {
    "echasnovski/mini.ai",
    dependencies = {
        "echasnovski/mini.extra",
    },
    event = "VeryLazy",
    -- TODO: Migrate treesitter's text objects to this
    opts = function()
        return {
            custom_textobjects = {
                ["i"] = require('mini.extra').gen_ai_spec.indent(),
            }
        }
    end,
}
