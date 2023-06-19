if vim.g.vscode then
    require "user.vscode"
    return
end

if vim.g.neovide then
    require "user.neovide"
end

require "user.impatient"

require "user.options"
require "user.keymaps"
require "user.plugins"

require "user.autoreload_config"

-- require "user.cinnamon"
require "user.neodev"
require "user.theme"
require "user.mini"
require "user.nvim-tree"
require "user.telescope"
require "user.trouble"
require "user.project_nvim"

require "user.gitsigns"
require "user.cmp"
require "user.copilot"
require "user.treesitter"
require "user.lsp"
require "user.neotest"
require "user.toggleterm"
require "user.luasnip"
require "user.marks"
require "user.heirline"
require "user.chat_gpt"
require "user.diffview"
-- require "user.noice"

require "user.filetype"
