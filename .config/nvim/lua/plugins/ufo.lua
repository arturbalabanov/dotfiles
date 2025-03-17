return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  init = function()
    vim.o.foldcolumn = '0' -- '1' is not bad
    vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  opts = {
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
  },
  keys = {
    { 'zR', function() require("ufo").openAllFolds() end,         desc = "open all folds" },
    { 'zM', function() require("ufo").closeAllFolds() end,        desc = "close all folds" },
    { 'zr', function() require("ufo").openFoldsExceptKinds() end, desc = "open folds except kinds" },
    { 'zm', function() require("ufo").closeFoldsWith() end,       desc = "close folds with" },
    {
      '<S-Tab>',
      function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()

        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = "Peek a fold",
    },
    { '<Tab>', 'za', desc = "Toggle fold" },
  },
}

-- peek a fold with <Shift+Tab>
