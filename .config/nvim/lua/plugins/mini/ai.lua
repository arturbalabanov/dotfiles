return {
    "echasnovski/mini.ai",
    dependencies = {
        "echasnovski/mini.extra",
    },
    -- event = "VeryLazy",
    -- TODO: Migrate treesitter's text objects to this
    opts = function()
        return {
            custom_textobjects = {
                ["i"] = require("mini.extra").gen_ai_spec.indent(),
                -- ["f"] = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                -- ["c"] = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
                -- ["a"] = require("mini.ai").gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
                -- TODO: Add a comment block textobject with C
            },
        }
    end,
}
