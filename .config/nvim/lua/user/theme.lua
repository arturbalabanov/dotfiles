local status_ok, gruvbox = pcall(require, "gruvbox")
if not status_ok then
    return
end

local palette = require("gruvbox.palette")

gruvbox.setup({
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = false,
        operators = false,
        comments = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,    -- invert background for search, diffs, statuslines and errors
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

        NeotestFailed = { fg = palette.colors.neutral_red },
        NeotestPassed = { fg = palette.colors.neutral_green },
        NeotestRunning = { fg = palette.colors.neutral_blue },
        NeotestSkipped = { fg = palette.colors.neutral_yellow },
        --
        -- adapter_name = "NeotestAdapterName",
        -- border = "NeotestBorder",
        -- dir = "NeotestDir",
        -- expand_marker = "NeotestExpandMarker",
        -- failed = "NeotestFailed",
        -- file = "NeotestFile",
        -- focused = "NeotestFocused",
        -- indent = "NeotestIndent",
        -- marked = "NeotestMarked",
        -- namespace = "NeotestNamespace",
        -- passed = "NeotestPassed",
        -- running = "NeotestRunning",
        -- select_win = "NeotestWinSelect",
        -- skipped = "NeotestSkipped",
        -- target = "NeotestTarget",
        -- test = "NeotestTest",
        -- unknown = "NeotestUnknown",
        -- watching = "NeotestWatching"
    },
    dim_inactive = false,
    transparent_mode = false,
})

vim.cmd.colorscheme("gruvbox")
