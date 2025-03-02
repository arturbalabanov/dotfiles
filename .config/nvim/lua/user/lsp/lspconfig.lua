local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local my_utils = require("user.utils")

-- ref: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local lsp_common = require("user.lsp.common")

lspconfig.pyright.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),

    handlers = {
        -- Disable all diagnostics from  pyright, use local tools like flake8, ruff etc. for that
        -- We make an exception for reportUndefinedVariable as this is necesasry for stevanmilic/nvim-lspimport
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
            function(err, result, ctx, config)
                result.diagnostics = vim.tbl_filter(
                    function(diagnostic) return diagnostic.code == "reportUndefinedVariable" end,
                    result.diagnostics
                )
                vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
            end,
            {}
        )
    },
})

lspconfig.lua_ls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    settings = {
        Lua = {
            format = {
                enable = true,
                -- Put format options here
                -- NOTE: the value should be STRING!!

                -- ref: https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
                -- (convert to cammel case)

                defaultConfig = {
                    quoteStyle = "double",
                },
            },
            workspace = {
                checkThirdParty = false,
            },
            diagnostics = {
                globals = { 'vim' }
            },
        },
    },
})

lspconfig.gopls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.terraformls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.ansiblels.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.ruby_lsp.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.buf_ls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.rust_analyzer.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    settings = {
        ['rust-analyzer'] = {
            check = {
                command = "clippy",
            },
            diagnostics = {
                enable = true,
            }
        }
    }
})

lspconfig.taplo.setup {
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

lspconfig.dockerls.setup {
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

lspconfig.yamlls.setup {
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
}
