local my_utils = require("user.utils")

local M = {}

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



local function setup_auto_format_autocmd(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
        buffer = bufnr,
        callback = function(event)
            local enabled = lsp_formatting_enabled[event.buf] or true

            if not enabled then
                my_utils.simple_notify("LSP Formatting is disabled for buf " .. bufnr .. ", skipping", "warn")
                return
            end

            vim.lsp.buf.format()
        end
    })
end

M.on_attach = function(client, bufnr)
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    if filetype == "python" then
        require("user.py_venv").on_attach(client, bufnr)
    end

    if client.supports_method("textDocument/formatting") then
        setup_auto_format_autocmd(client, bufnr)
    end

    if client.supports_method("textDocument/inlayHint") or client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
end

my_utils.nkeymap("gD", vim.lsp.buf.hover)

return M
