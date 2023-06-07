local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

local theme
local status_ok, palette = pcall(require, "gruvbox.palette")
if status_ok then
    local custom_gruvbox = require('lualine.themes.gruvbox')

    for mode, _ in pairs(custom_gruvbox) do
        custom_gruvbox[mode].c.bg = palette.dark0_hard
    end

    theme = custom_gruvbox
else
    theme = 'auto'
end


local lsp_location = function()
    return require('lspsaga.symbolwinbar'):get_winbar() or ""
end

lualine.setup {
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { {
            'mode',
            fmt = function(str) return str:sub(1, 1) end, -- Only show the first letter
        } },
        lualine_b = { 'diagnostics' },
        lualine_c = { 'branch', {
            'diff',
            colored = true, -- Displays a colored diff status if set to true
            diff_color = {
                -- Same color values as the general color option can be used here.
                added    = { fg = 'dark_green', gui = 'bold' },       -- Changes the diff's added color
                modified = { fg = 'yellow', gui = 'bold' },           -- Changes the diff's modified color
                removed  = { fg = 'red', gui = 'bold' },              -- Changes the diff's removed color you
            },
            symbols = { added = '+', modified = '~', removed = '-' }, -- Changes the symbols used by the diff.
        } },
        lualine_x = { {
            'filename',
            path = 1, -- Relative path to CWD
        } },
        lualine_y = { 'encoding', 'fileformat', 'filetype' },
        lualine_z = { 'progress', 'location' }
    },
    extensions = {}
}
