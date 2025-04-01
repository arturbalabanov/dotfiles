local cmd = vim.cmd
local utils = require("user.utils")

-- Use Space as a leader key
vim.g.mapleader = ' '

utils.ikeymap("jj", "<Esc>")
utils.nkeymap(";", ":", { silent = false })

-- Use vv to select current line without leading and trailing indentation
utils.nkeymap("vv", "^vg_")

-- Use Shift+K and Shift+L to navigate tabs
utils.nkeymap("K", cmd.tabn)
utils.nkeymap("J", cmd.tabp)

utils.nkeymap("<M-h>", function() cmd.wincmd("h") end)
utils.nkeymap("<M-j>", function() cmd.wincmd("j") end)
utils.nkeymap("<M-k>", function() cmd.wincmd("k") end)
utils.nkeymap("<M-l>", function() cmd.wincmd("l") end)

-- Reselect visual block after indent/dedent
utils.vkeymap("<", "<gv")
utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
utils.nkeymap("H", "^")
utils.nkeymap("L", "$")
utils.vkeymap("L", "g_")

-- Toggle folds with <Tab>
utils.nkeymap("<Tab>", "za")

-- Toggle the line numbers with <F1>
utils.nkeymap("<F1>", ":set invnumber<CR>")

-- Clear highlight search with ,/
utils.nkeymap(",/", cmd.nohlsearch)
