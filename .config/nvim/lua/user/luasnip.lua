local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
    return
end

local luasnip_loaders = require("luasnip.loaders")

local vs_code_snippets = require("luasnip.loaders.from_vscode")
-- FIXME: duplicated with lua/user/scisors.lua
local CUSTOM_SNIPPETS_PATH = vim.fn.stdpath("config") .. "/snippets/"

vs_code_snippets.lazy_load()
vs_code_snippets.lazy_load({ paths = { CUSTOM_SNIPPETS_PATH } })
