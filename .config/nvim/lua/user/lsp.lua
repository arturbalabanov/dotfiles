local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
    return
end

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

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


require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua", "pyright" },
    automatic_installation = true,
})

require('lspconfig').sumneko_lua.setup({
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
