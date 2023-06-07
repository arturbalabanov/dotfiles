local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
    return
end

bufferline.setup({
    options = {
        mode = 'tabs',
        -- can also be a table containing 2 custom separators [focused and unfocused]. eg: { '|', '|' }
        -- separator_style = "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
        separator_style = 'thin',
        indicator = {
            icon = '▎',
            style = 'icon',
        },
        show_close_icon = false,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                separator = true
            }
        },
    },
    highlights = {
        indicator_selected = {
            fg = { highlight = "GruvboxBlue", attribute = "fg" },
        },
    }
})
