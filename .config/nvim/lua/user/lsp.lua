local status_ok, neodev = pcall(require, "neodev")
if not status_ok then
    return
end

neodev.setup({})

local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local status_ok, lspsaga = pcall(require, "lspsaga")
if not status_ok then
    return
end

local path = require('lspconfig/util').path

lspsaga.setup({
    lightbulb = {
        enable = true,
        sign = false,
        virtual_text = true,
    },
    symbol_in_winbar = {
        enable = false,
    }
})


-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>r', function() vim.cmd.Lspsaga('rename') end, opts)
vim.keymap.set('n', '<leader>a', function() vim.cmd.Lspsaga('code_action') end, opts)
vim.keymap.set('n', 'gd', function() vim.cmd.Lspsaga('goto_definition') end, opts)
vim.keymap.set('n', 'gp', function() vim.cmd.Lspsaga('peek_definition') end, opts)
vim.keymap.set('n', 'gD', function() vim.cmd.Lspsaga('hover_doc') end, opts)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Diagnostics
vim.diagnostic.config {
    virtual_text = true,
    underline = true,
    float = {
        source = 'always'
    }
}

vim.fn.sign_define("DiagnosticSignError", { text = "", linehl = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", linehl = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", linehl = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", linehl = "", texthl = "DiagnosticSignHint", numhl = "" })

-- Open a new defintion in a new tab if not in the same file

local original_handler = vim.lsp.handlers['textDocument/definition']
vim.lsp.handlers['textDocument/definition'] = function(err, result, ctx, config)
    if result == nil or vim.tbl_isempty(result) then
        return original_handler(err, result, ctx, config)
    end

    local original_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command('tabnew')
    local tab_buf = vim.api.nvim_get_current_buf()

    local original_result = original_handler(err, result, ctx, config)

    if vim.api.nvim_get_current_buf() == original_buf then
        -- close the new tab buffer if we jumped to the same buffer
        vim.api.nvim_command(tab_buf .. 'bd')
    end

    return original_result
end


local lsp_formatting_enabled = true

vim.api.nvim_create_user_command('ToggleLSPFormatting', function()
    lsp_formatting_enabled = not lsp_formatting_enabled

    if lsp_formatting_enabled then
        print("LSP Formatting ENABLED")
    else
        print("LSP Formatting DISABLED")
    end
end, {})

local on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('LspFormatting', { clear = false }),
        buffer = bufnr,
        callback = function()
            if lsp_formatting_enabled then
                vim.lsp.buf.format()
            else
                print("LSP Formatting is disabled, skipping")
            end
        end
    })
end

local function get_python_path(workspace)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end

    -- Find and use virtualenv in workspace directory.
    for _, pattern in ipairs({ '*', '.*' }) do
        local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
        if match ~= '' then
            return path.join(path.dirname(match), 'bin', 'python')
        end
    end

    -- Fallback to system Python.
    return exepath('python3') or exepath('python') or 'python'
end

local ensure_installed = { "lua_ls", "pyright", "gopls" }
require("mason").setup()
require("mason-null-ls").setup({
    ensure_installed = ensure_installed,
    automatic_installation = false,
    automatic_setup = true, -- Recommended, but optional
    handlers = {},
})
require("null-ls").setup({
    sources = {
        -- Anything not supported by mason.
    }
})

require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
    automatic_installation = true,
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    -- before_init = function(_, config)
    --     config.settings.python.pythonPath = get_python_path(config.root_dir)
    -- end,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
            },
        },
    },
})

lspconfig.gopls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

lspconfig.terraformls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
