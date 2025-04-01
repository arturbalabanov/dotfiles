if vim.g.vscode then
    require "user.vscode"
    return
end

require "user.impatient"

require "user.options"
require "user.keymaps"
require "user.plugins"

require "user.theme"
require "user.lualine"
require "user.bufferline"
require "user.nvim-tree"
require "user.telescope"
require "user.trouble"

require "user.cmp"
require "user.treesitter"
require "user.lsp"
