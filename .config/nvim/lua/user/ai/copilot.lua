local my_utils = require("user.utils")

local status_ok, copilot = pcall(require, "copilot")
if not status_ok then
    my_utils.simple_notify("Could not load copilot.lua", "error")
    return
end

copilot.setup({
    panel = { enabled = false },
    suggestion = {
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
            accept = "<C-j>",
            next = "<C-k>",
            prev = false,
            dismiss = "<Esc>",
        },
    },
})
