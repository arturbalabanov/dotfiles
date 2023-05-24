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

local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

local path = util.path

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

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- function on_attach(client, bufnr)
--         if client.supports_method("textDocument/formatting") then
--             vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--             vim.api.nvim_create_autocmd("BufWritePre", {
--                 group = augroup,
--                 buffer = bufnr,
--                 callback = function()
--                     vim.lsp.buf.format({ bufnr = bufnr })
--                 end,
--             })
--         end
--     end
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

    -- Find and use virtualenv via various venv tools

    -- pdm:
    local match = vim.fn.glob(path.join(workspace, 'pdm.lock'))
    if match ~= '' then
        return vim.fn.trim(vim.fn.system('pdm venv --python in-project'))
    end

    -- poetry:
    local match = vim.fn.glob(path.join(workspace, 'poetry.lock'))
    if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
        return path.join(venv, 'bin', 'python')
    end

    -- pipenv:
    local match = vim.fn.glob(path.join(workspace, 'Pipfile.lock'))
    if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('pipenv --venv'))
        return path.join(venv, 'bin', 'python')
    end

    -- Fallback to system Python.
    return exepath('python3') or exepath('python') or 'python'
end

-- TODO: Get rid of Mason and just use local tools everywhere
-- local ensure_installed = { "lua_ls", "pyright", "ruff_lsp", "gopls" }
-- require("mason").setup({
--     providers = {
--         -- "mason.providers.registry-api",
--         "mason.providers.client",
--     },
-- })
-- require("mason-null-ls").setup({
--     ensure_installed = ensure_installed,
--     automatic_installation = false,
--     automatic_setup = false,
--     handlers = {},
-- })
-- require("mason-lspconfig").setup({
--     ensure_installed = ensure_installed,
--     automatic_installation = true,
-- })

-- require("null-ls").setup({
--     sources = {
--         -- Anything not supported by mason.
--     }
-- })

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        -- diagnostics
        null_ls.builtins.diagnostics.ruff.with{
            only_local = true,
        },
        null_ls.builtins.diagnostics.flake8.with{
            only_local = true,
        },
        null_ls.builtins.diagnostics.mypy.with{
            only_local = true,
        },

        -- formatting
        null_ls.builtins.formatting.ruff.with{
            only_local = true,
        },
        null_ls.builtins.formatting.black.with{
            only_local = true,
        },
        null_ls.builtins.formatting.isort.with{
            only_local = true
        },
    },
    on_attach = on_attach,
})

lspconfig.pyright.setup({
    on_attach = function(client, buffer) 
        -- Disable all diagnostics from  pyright, use local tools like flake8, ruff etc. for that
        client.handlers["textDocument/publishDiagnostics"] = function(...) end
        return on_attach(client, buffer)
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path(config.root_dir)
    end,
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

lspconfig.gopls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

lspconfig.terraformls.setup({
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
