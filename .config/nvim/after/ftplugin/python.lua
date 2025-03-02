local my_utils = require("user.utils")

vim.cmd([[setlocal colorcolumn=120]])
vim.cmd([[setlocal textwidth=120]])

my_utils.nkeymap("gf", function() my_utils.move_jump_to_new_tab(vim.cmd.PytrizeJumpFixture) end)
