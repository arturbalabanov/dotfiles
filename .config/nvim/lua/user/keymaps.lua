local my_utils = require("user.utils")

-- Use Space as a leader key
vim.g.mapleader = ' '

my_utils.ikeymap("jj", "<Esc>")
my_utils.nkeymap(";", ":", { silent = false })

-- Use vv to select current line without leading and trailing indentation
my_utils.nkeymap("vv", "^vg_")

-- Reselect visual block after indent/dedent
my_utils.vkeymap("<", "<gv")
my_utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
my_utils.nkeymap("H", "^")
my_utils.vkeymap("H", "^")
my_utils.nkeymap("L", "$")
my_utils.vkeymap("L", "g_")

-- Toggle folds with <Tab>
my_utils.nkeymap("<Tab>", "za")

-- Toggle the line numbers with <F1>
my_utils.nkeymap("<F1>", ":set invnumber<CR>")

-- Clear highlight search with ,/
my_utils.nkeymap(",/", vim.cmd.nohlsearch)

-- Move between windows and tabs
my_utils.nkeymap("gh", { vim.cmd.wincmd, "h" })
my_utils.nkeymap("gj", { vim.cmd.wincmd, "j" })
my_utils.nkeymap("gk", { vim.cmd.wincmd, "k" })
my_utils.nkeymap("gl", { vim.cmd.wincmd, "l" })
my_utils.nkeymap("K", vim.cmd.tabn)
my_utils.nkeymap("J", vim.cmd.tabp)

my_utils.nkeymap("<C-u>", "gUiw")
my_utils.ikeymap("<C-u>", "<C-o>gUiw")
