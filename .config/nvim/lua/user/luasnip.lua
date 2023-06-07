local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
    return
end

local vs_code_snippets = require("luasnip.loaders.from_vscode")
local CUSTOM_SNIPPETS_PATH = vim.fn.stdpath("config") .. "/snippets/"

vs_code_snippets.lazy_load()
vs_code_snippets.lazy_load({ paths = { CUSTOM_SNIPPETS_PATH } })

vim.api.nvim_create_user_command('LuaSnipEdit', function()
    -- TODO: Use plenary.filetype
    local filetype = vim.bo.filetype
    -- TODO: Use plenary.path
    local snippets_location = CUSTOM_SNIPPETS_PATH .. filetype .. ".json"

    vim.cmd.split(snippets_location)
    -- TODO: Make sure the file is referenced in CUSTOM_SNIPPETS_PATH / package.json
    --       and if not, add it there
    -- TODO: If file is empty, add a template
end, {})
