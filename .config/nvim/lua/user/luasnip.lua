local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
    return
end

local luasnip_loaders = require("luasnip.loaders")

local vs_code_snippets = require("luasnip.loaders.from_vscode")
local CUSTOM_SNIPPETS_PATH = vim.fn.stdpath("config") .. "/snippets/"

vs_code_snippets.lazy_load()
vs_code_snippets.lazy_load({ paths = { CUSTOM_SNIPPETS_PATH } })

-- TODO: Clean up this mess and make it actually work
vim.api.nvim_create_user_command('LuaSnipEdit', function()
    luasnip_loaders.edit_snippet_files({
        ft_filter = function(filetype)
            return filetype == "python"
        end,
        format = function(filepath, source_name)
            return CUSTOM_SNIPPETS_PATH .. filepath
            -- return string.format("%s: %s", source_name, filepath)
        end,
        edit = function(filepath)
            vim.cmd.split(filepath)
        end,

        extend = function(filetype, paths)
            return {
                {
                    "CUSTOM: " .. filetype,
                    CUSTOM_SNIPPETS_PATH .. filetype .. '.json'
                },
            }
        end
    })
end, {})
