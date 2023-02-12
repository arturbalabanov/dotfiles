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


lualine.setup {
    options = {
        icons_enabled = true,
        theme = theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
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
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    extensions = {}
}
