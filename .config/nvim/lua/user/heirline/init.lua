-- ref: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

local heirline = require("heirline")

local my_utils = require("user.utils")


local SELECTED_THEME = 'tokyonight_moon'

local themes = my_utils.opt_require("user.heirline.themes")
local StatusLine = my_utils.opt_require("user.heirline.statusline")
local TabLine = my_utils.opt_require("user.heirline.tabline")

heirline.setup({
    statusline = StatusLine,
    tabline = TabLine,
    opts = {
        colors = vim.tbl_deep_extend("keep", themes[SELECTED_THEME](), themes['common']),
    }
})

vim.o.showtabline = 2
vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
