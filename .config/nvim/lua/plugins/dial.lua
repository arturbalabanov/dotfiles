return {
    "monaqa/dial.nvim",
    keys = {
        { "<C-s>",  function() require("dial.map").manipulate("increment", "normal") end,  mode = "n", desc = "dial: increment" },
        { "<C-x>",  function() require("dial.map").manipulate("decrement", "normal") end,  mode = "n", desc = "dial: decrement" },
        { "g<C-s>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n", desc = "dial: continuously increment" },
        { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n", desc = "dial: continuously decrement" },
        { "<C-s>",  function() require("dial.map").manipulate("increment", "visual") end,  mode = "v", desc = "dial: increment" },
        { "<C-x>",  function() require("dial.map").manipulate("decrement", "visual") end,  mode = "v", desc = "dial: decrement" },
        { "g<C-s>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "dial: continuously increment" },
        { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "dial: continuously decrement" },
    },
    config = function()
        local augend = require("dial.augend")

        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal_int,
                augend.integer.alias.hex,
                augend.constant.alias.bool,
                augend.semver.alias.semver,
                augend.date.alias["%Y/%m/%d"],
                augend.date.alias["%d/%m/%Y"],
                augend.date.alias["%Y-%m-%d"],
                -- TODO: logging symbols
                augend.paren.alias.quote,
                -- augend.paren.alias.brackets,
                -- TODO: Only for lua
                -- augend.paren.alias.lua_str_literal,
                -- TODO: Add a similar for python (e.g. f-strings, t-strings etc)
                -- augend.paren.alias.rust_str_literal,
                -- TODO: only for markdown
                -- augend.misc.alias.markdown_header,
                augend.constant.new {
                    elements = { "and", "or" },
                    word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
                    cyclic = true, -- "or" is incremented into "and".
                },
                augend.constant.new {
                    elements = { "&&", "||" },
                    word = false,
                    cyclic = true,
                },
                augend.constant.new {
                    elements = { "def", "async def" },
                    match_before_cursor = true,
                },
                augend.constant.new {
                    elements = { "log.debug", "log.info", "log.warning", "log.error", "log.critical" },
                    match_before_cursor = true,
                },
                augend.constant.new {
                    elements = { "logger.debug", "logger.info", "logger.warning", "logger.error", "logger.critical" },
                    match_before_cursor = true,
                },
            },
        })
    end,
}
