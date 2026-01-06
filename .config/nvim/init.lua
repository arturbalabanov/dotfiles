local status_ok, my_utils = pcall(require, "user.utils")

local opt_require
if status_ok then
    opt_require = my_utils.opt_require
else
    opt_require = require
end

if vim.g.vscode then
    opt_require("user.vscode")
    return
end

if vim.g.neovide then
    opt_require("user.neovide")
end

-- Enable the experimental vim loader for faster startup (a replacement of impatient.nvim)
vim.loader.enable()

require("utils.plugin").delay_notifications_until_patched({ timeout_ms = 500 })

opt_require("user.options")
opt_require("user.keymaps")
opt_require("user.diagnostic")
opt_require("user.commands")
opt_require("user.autocmds")
opt_require("user.autoreload_config")

opt_require("user.lazy")
