local status_ok, my_utils = pcall(require, "user.utils")

local opt_require
if status_ok then
    opt_require = my_utils.opt_require
else
    opt_require = require
end

if vim.g.vscode then
    opt_require "user.vscode"
    return
end

if vim.g.neovide then
    opt_require "user.neovide"
end

opt_require "user.impatient"

opt_require "user.options"
opt_require "user.keymaps"
opt_require "user.commands"

opt_require "user.theme"
opt_require "user.plugins"

opt_require "user.substitute"
opt_require "user.scroll_eof"

opt_require "user.better_escape"

opt_require "user.autoreload_config"
opt_require "user.treesitter"
opt_require "user.treesj"
opt_require "user.guess_indent"

opt_require "user.neodev"
opt_require "user.mini"
opt_require "user.nvim-tree"
opt_require "user.dressing"
opt_require "user.telescope"
opt_require "user.trouble"
opt_require "user.todo_comments"
opt_require "user.project_nvim"
opt_require "user.overseer"
opt_require "user.pytrize"

opt_require "user.rulebook"
opt_require "user.indent_blankline"
opt_require "user.git"
opt_require "user.cmp"
opt_require "user.lsp"
opt_require "user.neotest"
opt_require "user.coverage"
opt_require "user.toggleterm"
opt_require "user.dap"
opt_require "user.luasnip"
opt_require "user.scissors"
opt_require "user.marks"
opt_require "user.heirline"
opt_require "user.incline"
opt_require "user.grug_far"
opt_require "user.ai"
opt_require "user.focus"
opt_require "user.noice"
opt_require "user.ufo"
opt_require "user.refactoring"
opt_require "user.codesnap"

opt_require "user.tmux"
