local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local status_ok, lspsaga = pcall(require, "lspsaga")
if not status_ok then
    return
end

local status_ok, def_or_refs = pcall(require, "definition-or-references")
if not status_ok then
    return
end

local status_ok, goto_preview = pcall(require, 'goto-preview')
if not status_ok then
    return
end


local my_utils = require("user.utils")


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

goto_preview.setup {
    width = 120,                                         -- Width of the floating window
    height = 15,                                         -- Height of the floating window
    border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
    default_mappings = false,                            -- Bind default mappings
    debug = false,                                       -- Print debug information
    opacity = 0,                                         -- 0-100 opacity level of the floating window where 100 is fully transparent.
    resizing_mappings = false,                           -- Binds arrow keys to resizing the floating window.
    post_open_hook = nil,                                -- A function taking two arguments, a buffer and a window to be ran as a hook.
    references = {                                       -- Configure the telescope UI for slowing the references cycling window.
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
    },
    -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
    focus_on_open = true,                                        -- Focus the floating window when opening it.
    dismiss_on_move = false,                                     -- Dismiss the floating window when moving the cursor.
    force_close = true,                                          -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
    bufhidden = "wipe",                                          -- the bufhidden option to set on the floating window. See :h bufhidden
    stack_floating_preview_windows = true,                       -- Whether to nest floating windows
    preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
}

-- ref: https://github.com/KostkaBrukowa/nvim-config/blob/master/lua/dupa/definitions_or_references/entries.lua
local function lsp_refs_in_telescope(result)
    local entry_display = require("telescope.pickers.entry_display")
    local make_entry = require("telescope.make_entry")

    local cwd = vim.loop.cwd()

    local function make_telescope_entries_from()
        local configuration = {
            { max_width = 40 },
            {},
        }

        local displayer = entry_display.create({ separator = " ", items = configuration })

        local make_display = function(entry)
            local rel_filename = require("plenary.path"):new(entry.filename):make_relative(cwd)
            local trimmed_text = entry.text:gsub("^%s*(.-)%s*$", "%1")

            return displayer({
                { rel_filename, "TelescopeResultsIdentifier" },
                { trimmed_text },
            })
        end

        return function(entry)
            local rel_filename = require("plenary.path"):new(entry.filename):make_relative(cwd)

            return make_entry.set_default_entry_mt({
                value = entry,
                ordinal = rel_filename .. " " .. entry.text,
                display = make_display,

                bufnr = entry.bufnr,
                filename = entry.filename,
                lnum = entry.lnum,
                col = entry.col - 1,
                text = entry.text,
                start = entry.start,
                finish = entry.finish,
            }, {})
        end
    end

    require("telescope.pickers")
        .new({}, {
            prompt_title = "LSP References",
            finder = require("telescope.finders").new_table({
                results = vim.lsp.util.locations_to_items(result, "utf-16"),
                entry_maker = make_telescope_entries_from(),
            }),
            sorter = require("telescope.config").values.generic_sorter({}),
            previewer = require("telescope.config").values.qflist_previewer({}),
            layout_strategy = "vertical",
            initial_mode = "normal",
            wrap_results = false,
        })
        :find()
end

def_or_refs.setup({
    on_references_result = lsp_refs_in_telescope,
})

my_utils.nkeymap("gd", def_or_refs.definition_or_references)

my_utils.nkeymap("<leader>r", function() vim.cmd.Lspsaga("rename") end)
my_utils.nkeymap("<leader>a", function() vim.cmd.Lspsaga("code_action") end)
my_utils.nkeymap("gD", function() vim.cmd.Lspsaga("hover_doc") end)

-- my_utils.nkeymap("gp", function() vim.cmd.Lspsaga("peek_definition") end)
my_utils.nkeymap("gp", goto_preview.goto_preview_definition)

my_utils.nkeymap("<leader>e", vim.diagnostic.open_float)
my_utils.nkeymap("[d", vim.diagnostic.goto_prev)
my_utils.nkeymap("]d", vim.diagnostic.goto_next)

-- Diagnostics
vim.diagnostic.config {
    virtual_text = true,
    underline = true,
    float = {
        source = "always"
    }
}

vim.fn.sign_define("DiagnosticSignError", { text = "", linehl = "", texthl = "DiagnosticSignError", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", linehl = "", texthl = "DiagnosticSignWarn", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", linehl = "", texthl = "DiagnosticSignInfo", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", linehl = "", texthl = "DiagnosticSignHint", numhl = "" })

-- Open a new defintion in a new tab if not in the same file

local original_handler = vim.lsp.handlers["textDocument/definition"]
vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    if result == nil or vim.tbl_isempty(result) then
        return original_handler(err, result, ctx, config)
    end

    local original_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command("tabnew")
    local tab_buf = vim.api.nvim_get_current_buf()

    local original_result = original_handler(err, result, ctx, config)

    if vim.api.nvim_get_current_buf() == original_buf then
        -- close the new tab buffer if we jumped to the same buffer
        vim.api.nvim_command(tab_buf .. "bd")
    end

    return original_result
end


local lsp_formatting_enabled = {}

vim.api.nvim_create_user_command("ToggleLSPFormatting", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local enabled_in_buf = not (lsp_formatting_enabled[bufnr] or true)

    lsp_formatting_enabled[bufnr] = enabled_in_buf

    local enabled_str = "ENABLED"

    if not enabled_in_buf then
        enabled_str = "DISABLED"
    end

    my_utils.simple_notify("LSP Formatting " .. enabled_str .. " for buffer " .. bufnr)
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
--

local lsp_signature_config = {
    max_height = 3,
    max_width = 120,
    handler_opts = {
        border = "shadow" -- double, rounded, single, shadow, none, or a table of borders
    },
    floating_window = true,

    hint_enable = false,
    -- hint_scheme = "Keyword", -- highlight the virtual text as if it was a Keyword, so that it's more visible
}

local on_attach = function(client, bufnr)
    require("lsp_signature").on_attach(lsp_signature_config, bufnr)

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatting", { clear = false }),
        buffer = bufnr,
        callback = function(event)
            local enabled = lsp_formatting_enabled[event.buf] or true

            if enabled then
                vim.lsp.buf.format()
            else
                my_utils.simple_notify("LSP Formatting is disabled for buf " .. bufnr .. ", skipping", "warn")
            end
        end
    })
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
        null_ls.builtins.diagnostics.ruff.with {
            prefer_local = true,
        },
        null_ls.builtins.diagnostics.flake8.with {
            prefer_local = true,
        },
        null_ls.builtins.diagnostics.mypy.with {
            prefer_local = true,
        },

        -- formatting
        null_ls.builtins.formatting.ruff.with {
            prefer_local = true,
        },
        null_ls.builtins.formatting.black.with {
            prefer_local = true,
        },
        null_ls.builtins.formatting.isort.with {
            prefer_local = true
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
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    -- before_init = function(_, config)
    --     config.settings.python.pythonPath = my_utils.get_python_path(config.root_dir)
    -- end,
    on_init = function(client)
        client.config.settings.python.pythonPath = my_utils.get_python_path(client.config.root_dir)
    end,
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
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
    on_attach = on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.terraformls.setup({
    on_attach = on_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
