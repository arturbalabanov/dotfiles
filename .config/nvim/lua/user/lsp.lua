local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

vim.diagnostic.config {
    virtual_text = true,
    underline = true,
    float = {
        source = 'always'
    }
}

local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<C-D>', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

    vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('LspFormatting', { clear = true }),
        buffer = bufnr,
        callback = function()
            vim.lsp.buf.format()
        end
    })
end

vim.fn.sign_define("DiagnosticSignError", { text = "", linehl = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", linehl = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", linehl = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", linehl = "", texthl = "DiagnosticSignHint", numhl = "" })

local ensure_installed = { "lua_ls", "pyright" }
require("mason").setup()
require("mason-null-ls").setup({
    ensure_installed = ensure_installed,
    automatic_installation = false,
    automatic_setup = true, -- Recommended, but optional
})
require("null-ls").setup({
    sources = {
        -- Anything not supported by mason.
    }
})

require 'mason-null-ls'.setup_handlers() -- If `automatic_setup` is true.

require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    automatic_installation = true,
})

require('lspconfig').lua_ls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        Lua = {
            diagnostics = {
                globals = {
                    "vim"
                }
            }
        }
    }
})

require('lspconfig').pyright.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
