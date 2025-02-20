local my_utils = require "user.utils"

local incline = require "incline"
local helpers = require "incline.helpers"
local devicons = require "nvim-web-devicons"
local colors = require("tokyonight.colors").setup()

incline.setup {
    window = {
        padding = 0,
        margin = { horizontal = 0 },
    },
    hide = {
        only_win = true, -- inline is hidden if there is only one window in the tabpage.
    },
    render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
            filename = '[No Name]'
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified
        return {
            ft_icon and { ft_icon, guifg = ft_color } or '',
            ' ',
            { filename, gui = modified and 'bold,italic' or 'bold' },
            ' ',
            guibg = colors.bg,
        }
    end,
}
