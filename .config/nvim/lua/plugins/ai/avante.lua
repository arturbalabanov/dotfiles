-- refs:
--    * https://github.com/yetone/avante.nvim
--    * https://github.com/yetone/avante.nvim/wiki/Recipe-and-Tricks#advanced-shortcuts-for-frequently-used-queries-756

return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {},
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        -- "zbirenbaum/copilot.lua", -- for providers='copilot'  -- TODO: re-enable
        "HakonHarnes/img-clip.nvim", -- support for image pasting
        "MeanderingProgrammer/render-markdown.nvim",
    },
    build = "make",
    -- config = function()
    --     require('avante_lib').load()
    -- end,
    keys = {
        { "<F1>", "<cmd>AvanteToggle<CR>", mode = { "n", "i" }, desc = "Toggle Avante" },
    },
}
