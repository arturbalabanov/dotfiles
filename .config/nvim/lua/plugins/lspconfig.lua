-- ref: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- TODO: There is duplication between this and conform
local function setup_auto_format_autocmd(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
        buffer = bufnr,
        callback = function(event)
            -- TODO: Use utils.get_var_or_default

            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end

            vim.lsp.buf.format()
        end,
    })
end

return {
    "neovim/nvim-lspconfig",
    opts = {
        additional_server_defintions = {
            -- TODO: Open a PR to add this to lspconfig
            -- ref: https://github.com/neovim/nvim-lspconfig/blob/master/CONTRIBUTING.md#adding-a-server-to-lspconfig
            tmux_language_server = {
                default_config = {
                    cmd = { "tmux-language-server" },
                    filetypes = { "tmux" },
                    single_file_support = true,
                },
                docs = {
                    description = [[
                        https://tmux-language-server.readthedocs.io/en/latest/

                        Language server for tmux configuration files.

                        `tmux-language-server` can be installed via `uv`:
                        ```sh
                        uv tool install tmux-language-server
                        ```

                        For more installation options, see [the docs](https://tmux-language-server.readthedocs.io/en/latest/resources/install.html).
                    ]],
                },
            },
        },
        server_configs = {
            ["*"] = function()
                return {
                    on_attach = function(client, bufnr)
                        require("auto-venv.contrib.lspconfig").on_attach(client, bufnr)

                        if client.supports_method("textDocument/formatting") then
                            setup_auto_format_autocmd(client, bufnr)
                        end

                        if
                            client.supports_method("textDocument/inlayHint")
                            or client.server_capabilities.inlayHintProvider
                        then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                    end,
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                }
            end,
            pyright = {
                handlers = {
                    -- Disable all diagnostics from  pyright, use local tools like flake8, ruff etc. for that
                    -- We make an exception for reportUndefinedVariable as this is necesasry for stevanmilic/nvim-lspimport
                    ["textDocument/publishDiagnostics"] = vim.lsp.with(function(err, result, ctx, config)
                        result.diagnostics = vim.tbl_filter(function(diagnostic)
                            return diagnostic.code == "reportUndefinedVariable"
                        end, result.diagnostics)
                        vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
                    end, {}),
                },
            },
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                            path = {
                                "lua/?.lua",
                                "lua/?/init.lua",
                            },
                        },
                        format = {
                            --- we're using stylua for formatting via conform.nvim
                            enable = false,
                            -- -- Put format options here
                            -- -- NOTE: the value should be STRING!!
                            --
                            -- -- ref: https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
                            -- -- (convert to cammel case)
                            --
                            -- defaultConfig = {
                            --     quote_style = "double",
                            -- },
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/",
                                -- TODO: add these
                                -- '${3rd}/luv/library',
                                -- '${3rd}/busted/library',
                            },
                        },
                        diagnostics = {
                            globals = { "vim", "hs" },
                        },
                    },
                },
            },
            gopls = {},
            terraformls = {},
            -- ansiblels = {},
            ruby_lsp = {},
            buf_ls = {},
            rust_analyzer = {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        },
                        diagnostics = {
                            enable = true,
                        },
                    },
                },
            },
            taplo = {},
            dockerls = {},
            yamlls = {},
            jsonls = {},
            helm_ls = {},
            -- tmux_language_server = {},
        },
    },
    config = function(_, opts)
        for server_name, server_defintion in pairs(opts.additional_server_defintions) do
            if not require("lspconfig.configs")[server_name] then
                require("lspconfig.configs")[server_name] = server_defintion
            end
        end

        local default_server_opts = opts.server_configs["*"]

        if type(default_server_opts) == "function" then
            default_server_opts = default_server_opts()
        end

        if default_server_opts == nil then
            default_server_opts = {}
        end

        for server_name, server_opts in pairs(opts.server_configs) do
            if server_name ~= "*" then
                server_opts = vim.tbl_deep_extend("keep", server_opts, default_server_opts)

                if require("lspconfig")[server_name] then
                    require("lspconfig")[server_name].setup(server_opts)
                else
                    require("utils").error_fmt("LSP server '%s' not found in lspconfig", server_name)
                end
            end
        end
    end,
}
