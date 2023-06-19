local my_utils = require("user.utils")

vim.g.neovide_cursor_animation_length = 0
vim.o.guifont = "Hack Nerd Font:h14"
vim.opt.linespace = 0

vim.g.neovide_input_use_logo = 1            -- enable use of the logo (cmd) key

vim.keymap.set('v', '<D-c>', '"+y')         -- Copy
vim.keymap.set('n', '<D-s>', ':w<CR>')      -- Save
vim.keymap.set('v', '<D-c>', '"+y')         -- Copy
vim.keymap.set('n', '<D-v>', '"+P')         -- Paste normal mode
vim.keymap.set('v', '<D-v>', '"+P')         -- Paste visual mode
vim.keymap.set('c', '<D-v>', '<C-R>+')      -- Paste command mode
vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode

vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
-- TODO: FIXME
-- vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })

vim.cmd.cd(vim.fn.expand('$HOME') .. '/.config/nvim')
