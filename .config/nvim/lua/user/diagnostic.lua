local keymap = require("utils.keymap")
local utils = require("utils")

vim.diagnostic.config({
    virtual_text = {
        source = "if_many",
        current_line = true,
    },
    virtual_lines = false,
    underline = true,
    float = {
        source = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
})

keymap.set_n("<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap.set_n("<leader>dl", function()
    local old_config_value = vim.diagnostic.config().virtual_lines
    local new_config_value

    if old_config_value then
        new_config_value = false
    else
        new_config_value = { current_line = vim.diagnostic.config().virtual_text.current_line }
    end

    vim.diagnostic.config({ virtual_lines = new_config_value })

    local notify_msg

    if new_config_value then
        notify_msg = "ENABLED diagnostic virtual_lines"
    else
        notify_msg = "DISABLED diagnostic virtual_lines"
    end

    utils.simple_notify(notify_msg)
end, { desc = "Toggle diagnostic virtual_lines" })
keymap.set_n("<leader>da", function()
    local new_config_value = not vim.diagnostic.config().virtual_text.current_line

    vim.diagnostic.config({ virtual_text = { current_line = new_config_value } })

    if vim.diagnostic.config().virtual_lines then
        vim.diagnostic.config({ virtual_lines = { current_line = new_config_value } })
    end

    local notify_msg

    if new_config_value then
        notify_msg = "Showing diagnostic virtual_text for CURRENT line only"
    else
        notify_msg = "Showing diagnostic virtual_text for ALL lines"
    end

    utils.simple_notify(notify_msg)
end, { desc = "Toggle diagnostic virtual text for all lines" })

keymap.set_n("[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
keymap.set_n("]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
