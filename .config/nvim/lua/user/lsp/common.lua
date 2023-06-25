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


M.on_attach = function(client, bufnr)
    require("lsp_signature").on_attach(lsp_signature_config, bufnr)
    require("user.py_venv").on_attach(client, bufnr)

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

-- Open a new defintion (or reference, no matter if selected by telescope or not) in a new tab if not in the same file
local original_handler = vim.lsp.handlers["textDocument/definition"]
vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    my_utils.simple_notify("HERE")
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

return M
