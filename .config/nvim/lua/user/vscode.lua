local keymap = require("utils.keymap")

-- TODO: set desc instead of comments

-- jj -> Normal Mode is mapped in VSCode: keybindings.json
keymap.set_n(";", ":")

-- Use vv to select current line without leading and trailing indentation
keymap.set_n("vv", "^vg_")

-- Use Shift+K and Shift+L to navigate tabs
keymap.set_n("K", vim.cmd.Tabnext)
keymap.set_n("J", vim.cmd.Tabprevious)

-- Reselect visual block after indent/dedent
keymap.set_v("<", "<gv")
keymap.set_v(">", ">gv")

-- Easily go to the beginning/end of the line
keymap.set_n("H", "^")
keymap.set_n("L", "$")
keymap.set_v("L", "g_")

keymap.set_n("zM", function() vim.fn.VSCodeNotify('editor.foldAll') end)
keymap.set_n("zR", function() vim.fn.VSCodeNotify('editor.unfoldAll') end)
keymap.set_n("zc", function() vim.fn.VSCodeNotify('editor.fold') end)
keymap.set_n("zC", function() vim.fn.VSCodeNotify('editor.foldRecursively') end)
keymap.set_n("zo", function() vim.fn.VSCodeNotify('editor.unfold') end)
keymap.set_n("zO", function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end)
keymap.set_n("za", function() vim.fn.VSCodeNotify('editor.toggleFold') end)
keymap.set_n("<space>", function() vim.fn.VSCodeNotify('editor.toggleFold') end)

vim.opt.clipboard = "unnamedplus"
