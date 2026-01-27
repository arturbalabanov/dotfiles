return {
    "zbirenbaum/copilot.lua",
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
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
    },
}
