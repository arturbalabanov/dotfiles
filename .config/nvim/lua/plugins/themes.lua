return {
    -- NOTE: The Default theme has special config, see https://lazy.folke.io/spec/lazy_loading#-colorschemes

    {
        "folke/tokyonight.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        ---@class tokyonight.Config
        opts = {
            styles = {
                -- Style to be applied to different syntax groups
                -- Value is any valid attr-list value for `:help nvim_set_hl`
                comments = { italic = true },
                keywords = { italic = false },
                functions = { bold = true },
                variables = {},
                -- Background styles. Can be "dark", "transparent" or "normal"
                sidebars = "dark", -- style for sidebars, see below
                floats = "dark",   -- style for floating windows
            },
            -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
            sidebars = {
                "qf",
                "help",
                "terminal",
                "toggleterm",
                "neotest-summary",
                "NvimTree",
                "OverseerList",
                "Avante",
                "AvanteSelectedFiles",
                "AvanteInput",
            },
            on_highlights = function(hl, c)
                -- Don't highlight these groups as we rely on todo_comments for them
                hl["@text.note"] = {}
                hl["@text.todo"] = {}
                hl["@text.warning"] = {}
                hl["@text.danger"] = {}

                hl.MiniCursorword = { underline = true, sp = c.orange }
                hl.MiniCursorwordCurrent = { underline = true, sp = c.orange }

                hl.DiagnosticVirtualTextError = { fg = c.error }
                hl.DiagnosticVirtualTextWarn = { fg = c.warning }
                hl.DiagnosticVirtualTextInfo = { fg = c.info }
                hl.DiagnosticVirtualTextHint = { fg = c.hint }

                -- disable highlighting unused code as comments
                hl.DiagnosticUnnecessary = {}
            end,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight-moon]])
        end,
    },
    { "ellisonleao/gruvbox.nvim" },
    { "EdenEast/nightfox.nvim" },
    { "tiagovla/tokyodark.nvim" },
    { "scottmckendry/cyberdream.nvim" },
}

-- gruvbox.setup({
--     undercurl = true,
--     underline = true,
--     bold = true,
--     italic = {
--         strings = false,
--         operators = false,
--         comments = true,
--     },
--     strikethrough = true,
--     invert_selection = false,
--     invert_signs = false,
--     invert_tabline = false,
--     invert_intend_guides = false,
--     inverse = true,    -- invert background for search, diffs, statuslines and errors
--     contrast = "hard", -- can be "hard", "soft" or empty string
--     palette_overrides = {},
--     overrides = {
--         SignColumn = { bg = palette.colors.dark0_hard },
--         GruvboxRedSign = { bg = palette.colors.dark0_hard },
--         GruvboxGreenSign = { bg = palette.colors.dark0_hard },
--         GruvboxYellowSign = { bg = palette.colors.dark0_hard },
--         GruvboxBlueSign = { bg = palette.colors.dark0_hard },
--         GruvboxPurpleSign = { bg = palette.colors.dark0_hard },
--         GruvboxAquaSign = { bg = palette.colors.dark0_hard },
--         GruvboxOrangeSign = { bg = palette.colors.dark0_hard },
--
--         NeotestFailed = { fg = palette.colors.neutral_red },
--         NeotestPassed = { fg = palette.colors.neutral_green },
--         NeotestRunning = { fg = palette.colors.neutral_blue },
--         NeotestSkipped = { fg = palette.colors.neutral_yellow },
--
--         GitSignsCurrentLineBlame = { fg = palette.colors.gray },
--         GitSignsChange = { fg = palette.colors.bright_yellow },
--         GitSignsAdd = { fg = palette.colors.bright_green },
--     },
--     dim_inactive = false,
--     transparent_mode = false,
-- })
--
-- if vim.g.colors_name ~= 'gruvbox' then
--     gruvbox.load()
-- end
