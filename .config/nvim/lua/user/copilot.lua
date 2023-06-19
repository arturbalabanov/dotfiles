local my_utils = require("user.utils")

local status_ok, copilot = pcall(require, "copilot")
if not status_ok then
    my_utils.simple_notify("Could not load copilot.lua", "error")
    return
end

copilot.setup({
    suggestion = {
        auto_trigger = true,
        keymap = {
            accept = "<C-j>",
            next = "<C-l>",
            prev = "<C-h>",
            dismiss = "<C-k>",
        },
    },
})
