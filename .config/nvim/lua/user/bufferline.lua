local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
    return
end

bufferline.setup({
    options = {
        mode = 'tabs',
        separator_style = 'slant',
        show_close_icon = false,
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                separator = true
            }
        }
    },
})
