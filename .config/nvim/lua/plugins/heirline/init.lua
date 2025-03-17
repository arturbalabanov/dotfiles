-- ref: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

return {
    "rebelot/heirline.nvim",
    event = "UiEnter",
    dependencies = { "folke/tokyonight.nvim" },
    opts = function()
        local themes = require("plugins.heirline.themes")

        return {
            statusline = require("plugins.heirline.statusline"),
            tabline = require("plugins.heirline.tabline"),
            opts = {
                colors = vim.tbl_deep_extend("keep", themes[vim.g.colors_name](), themes['common']),
            }
        }
    end,
    init = function()
        vim.o.showtabline = 2
        vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
    end,
}
