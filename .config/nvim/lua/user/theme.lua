local status_ok, tokyonight = pcall(require, "tokyonight")
if not status_ok then
    return
end

tokyonight.setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "moon",         -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day",    -- The theme is used when the background is set to light
    transparent = false,    -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
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
    },
    day_brightness = 0.3,             -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false,             -- dims inactive windows
    lualine_bold = false,             -- When `true`, section headers in the lualine theme will be bold

    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    on_colors = function(c) end,

    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    on_highlights = function(hl, c)
        hl.MiniCursorword = { underline = true, sp = c.orange }
        hl.MiniCursorwordCurrent = { bg = c.fg_gutter }

        hl.DiagnosticVirtualTextError = { fg = c.error }
        hl.DiagnosticVirtualTextWarn = { fg = c.warning }
        hl.DiagnosticVirtualTextInfo = { fg = c.info }
        hl.DiagnosticVirtualTextHint = { fg = c.hint }
    end,
})

vim.cmd([[colorscheme tokyonight-moon]])

-- local status_ok, gruvbox = pcall(require, "gruvbox")
-- if not status_ok then
--     return
-- end
--
-- local palette = require("gruvbox.palette")
--
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
