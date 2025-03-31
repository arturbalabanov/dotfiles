return {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        { "<leader>aa", "<cmd>CodeCompanionActions<CR>",     desc = "Code Companion: Actions" },
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Code Companion: Toggle Chat" },
        { "<F1>",       "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "i" },                 desc = "Code Companion: Toggle Chat" },
    },
}
