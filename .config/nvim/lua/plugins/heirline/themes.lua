local utils = require("heirline.utils")

return {
    common = {
        diag_warn = utils.get_highlight("DiagnosticSignWarn").fg,
        diag_error = utils.get_highlight("DiagnosticSignError").fg,
        diag_hint = utils.get_highlight("DiagnosticSignHint").fg,
        diag_info = utils.get_highlight("DiagnosticSignInfo").fg,
        git_del = utils.get_highlight("diffRemoved").fg,
        git_add = utils.get_highlight("diffAdded").fg,
        git_change = utils.get_highlight("diffChanged").fg,
        buffer_tabpage_fill_fg = utils.get_highlight("BufferTabpageFill").fg
    },
    gruvbox = function()
        return {
            bg = utils.get_highlight("GruvboxBg0").bg,

            red = utils.get_highlight("GruvboxRed").fg,
            green = utils.get_highlight("GruvboxGreen").fg,
            blue = utils.get_highlight("GruvboxBlue").fg,
            orange = utils.get_highlight("GruvboxOrange").fg,
            purple = utils.get_highlight("GruvboxPurple").fg,
            aqua = utils.get_highlight("GruvboxAqua").fg,

            git_info_bg = utils.get_highlight("GruvboxBg1").fg,
            scrollbar_fg = utils.get_highlight("GruvboxAqua").fg,
            scrollbar_bg = utils.get_highlight("GruvboxBg2").fg,
            buffer_tabpage_fill_fg = utils.get_highlight("GruvboxGray").fg
        }
    end,
    ["tokyonight-moon"] = function()
        local colors = require("tokyonight.colors").setup()

        return {
            bg = colors.bg,

            red = colors.red,
            green = colors.green,
            blue = colors.blue,
            orange = colors.orange,
            purple = colors.purple,
            aqua = colors.teal,

            git_info_bg = colors.black,
            scrollbar_fg = colors.blue5,
            scrollbar_bg = colors.bg,
        }
    end,
}
