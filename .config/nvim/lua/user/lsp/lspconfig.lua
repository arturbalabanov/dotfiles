local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

-- ref: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

local lsp_common = require("user.lsp.common")

lspconfig.pyright.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    handlers = {
        -- Disable all diagnostics from  pyright, use local tools like flake8, ruff etc. for that
        ["textDocument/publishDiagnostics"] = function(...) end
    }
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

lspconfig.ruby_ls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.bufls.setup({
    on_attach = lsp_common.on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- TODO: Add JSON and YAML LSPs supporting schemas from:
-- * JSON (and hopefully YAML): https://www.schemastore.org/json/
-- Maybe use this LSP: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls

-- TODO: Add a TOML LSP supporting schemas from different sources (if schemas are a thing for TOML files)
-- e.g. https://taplo.tamasfe.dev/cli/usage/language-server.html

-- TODO: Add an LSP for Dockerfiles
-- e.g. https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#dockerls
