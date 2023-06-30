local opt_require = require("user.utils").opt_require

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
opt_require "user.plugins"

opt_require "user.substitute"

opt_require "user.autoreload_config"
opt_require "user.treesitter"
opt_require "user.treesj"
opt_require "user.theme"
opt_require "user.guess_indent"

opt_require "user.neodev"
opt_require "user.mini"
opt_require "user.nvim-tree"
opt_require "user.dressing"
opt_require "user.telescope"
opt_require "user.trouble"
opt_require "user.project_nvim"
opt_require "user.overseer"

opt_require "user.gitsigns"
opt_require "user.cmp"
opt_require "user.lsp"
opt_require "user.neotest"
opt_require "user.toggleterm"
opt_require "user.luasnip"
opt_require "user.marks"
opt_require "user.heirline"
opt_require "user.chat_gpt"
opt_require "user.diffview"
opt_require "user.focus"
opt_require "user.tint"
-- opt_require "user.noice"

opt_require "user.filetype"
