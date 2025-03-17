local CUSTOM_SNIPPETS_PATH = vim.fn.stdpath("config") .. "/snippets/"

return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v1.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local vs_code_snippets = require("luasnip.loaders.from_vscode")

            vs_code_snippets.lazy_load()
            vs_code_snippets.lazy_load({ paths = { CUSTOM_SNIPPETS_PATH } })
        end
    },
    {
        "chrisgrieser/nvim-scissors",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "nvim-telescope/telescope.nvim",
        },
        opts = {
            snippetDir = CUSTOM_SNIPPETS_PATH,
        },
    },
    "rafamadriz/friendly-snippets",
}
