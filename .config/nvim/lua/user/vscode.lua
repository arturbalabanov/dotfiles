local my_utils = require("user.utils")

-- jj -> Normal Mode is mapped in VSCode: keybindings.json
my_utils.nkeymap(";", ":")

-- Use vv to select current line without leading and trailing indentation
my_utils.nkeymap("vv", "^vg_")

-- Use Shift+K and Shift+L to navigate tabs
my_utils.nkeymap("K", vim.cmd.Tabnext)
my_utils.nkeymap("J", vim.cmd.Tabprevious)

-- Reselect visual block after indent/dedent
my_utils.vkeymap("<", "<gv")
my_utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
my_utils.nkeymap("H", "^")
my_utils.nkeymap("L", "$")
my_utils.vkeymap("L", "g_")

my_utils.nkeymap("zM", function() vim.fn.VSCodeNotify('editor.foldAll') end)
my_utils.nkeymap("zR", function() vim.fn.VSCodeNotify('editor.unfoldAll') end)
my_utils.nkeymap("zc", function() vim.fn.VSCodeNotify('editor.fold') end)
my_utils.nkeymap("zC", function() vim.fn.VSCodeNotify('editor.foldRecursively') end)
my_utils.nkeymap("zo", function() vim.fn.VSCodeNotify('editor.unfold') end)
my_utils.nkeymap("zO", function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end)
my_utils.nkeymap("za", function() vim.fn.VSCodeNotify('editor.toggleFold') end)
my_utils.nkeymap("<space>", function() vim.fn.VSCodeNotify('editor.toggleFold') end)

vim.opt.clipboard = "unnamedplus"
