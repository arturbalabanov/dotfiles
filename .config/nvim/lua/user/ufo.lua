local my_utils = require("user.utils")
local ufo = require('ufo')

vim.o.foldcolumn = '0' -- '1' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true


-- ref: https://github.com/nvim-treesitter/nvim-treesitter/tree/master/queries

vim.treesitter.query.set("lua", "folds", [[
  (function_definition) @fold
  (function_declaration) @fold
]])

vim.treesitter.query.set("python", "folds", [[
  (decorated_definition) @fold
  (function_definition) @fold
  (class_definition) @fold
]])

vim.treesitter.query.set("go", "folds", [[
  (function_declaration) @fold
  (method_declaration) @fold
  (type_declaration) @fold
]])

ufo.setup({
    open_fold_hl_timeout = 0, -- disable highlighting on opening folds
    close_fold_kinds_for_ft = {
        zsh = { 'marker' },
    },
    provider_selector = function(bufnr, filetype, buftype)
        local folds_per_ft = {
            zsh = 'marker',
            python = { 'treesitter' },
            lua = { 'marker', 'treesitter' },
            go = { 'treesitter' },
        }

        return folds_per_ft[filetype] or { 'marker', 'treesitter' }
    end
})


vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
-- peek a fold with <Shift+Tab>
vim.keymap.set('n', '<S-Tab>', function()
    local winid = ufo.peekFoldedLinesUnderCursor()

    if not winid then
        vim.lsp.buf.hover()
    end
end)

-- Toggle folds with <Tab>
my_utils.nkeymap("<Tab>", "za")
