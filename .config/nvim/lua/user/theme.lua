local status_ok, gruvbox = pcall(require, "gruvbox")
if not status_ok then
    return
end

local palette = require("gruvbox.palette")

gruvbox.setup({
    undercurl = true,
    underline = true,
    bold = true,
    italic = false,
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = "hard", -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {
        SignColumn = { bg = palette.colors.dark0_hard },
        GruvboxRedSign = { bg = palette.colors.dark0_hard },
        GruvboxGreenSign = { bg = palette.colors.dark0_hard },
        GruvboxYellowSign = { bg = palette.colors.dark0_hard },
        GruvboxBlueSign = { bg = palette.colors.dark0_hard },
        GruvboxPurpleSign = { bg = palette.colors.dark0_hard },
        GruvboxAquaSign = { bg = palette.colors.dark0_hard },
        GruvboxOrangeSign = { bg = palette.colors.dark0_hard },
    },
    dim_inactive = false,
    transparent_mode = false,
})

vim.cmd.colorscheme("gruvbox")
