local utils = require("user.utils")

-- jj -> Normal Mode is mapped in VSCode: keybindings.json
utils.nkeymap(";", ":")

-- Use vv to select current line without leading and trailing indentation
utils.nkeymap("vv", "^vg_")

-- Use Shift+K and Shift+L to navigate tabs
utils.nkeymap("K", vim.cmd.Tabnext)
utils.nkeymap("J", vim.cmd.Tabprevious)

-- Reselect visual block after indent/dedent
utils.vkeymap("<", "<gv")
utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
utils.nkeymap("H", "^")
utils.nkeymap("L", "$")
utils.vkeymap("L", "g_")

utils.nkeymap("zM", function() vim.fn.VSCodeNotify('editor.foldAll') end)
utils.nkeymap("zR", function() vim.fn.VSCodeNotify('editor.unfoldAll') end)
utils.nkeymap("zc", function() vim.fn.VSCodeNotify('editor.fold') end)
utils.nkeymap("zC", function() vim.fn.VSCodeNotify('editor.foldRecursively') end)
utils.nkeymap("zo", function() vim.fn.VSCodeNotify('editor.unfold') end)
utils.nkeymap("zO", function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end)
utils.nkeymap("za", function() vim.fn.VSCodeNotify('editor.toggleFold') end)
utils.nkeymap("<space>", function() vim.fn.VSCodeNotify('editor.toggleFold') end)

vim.opt.clipboard = "unnamedplus"
