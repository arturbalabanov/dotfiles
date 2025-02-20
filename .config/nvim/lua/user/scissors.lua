local my_utils = require("user.utils")
local my_luasnip = require("user.luasnip")
local scissors = require('scissors')

-- FIXME: duplicated with lua/user/luasnip.lua
local CUSTOM_SNIPPETS_PATH = vim.fn.stdpath("config") .. "/snippets/"

scissors.setup ({
    snippetDir = CUSTOM_SNIPPETS_PATH,
})
