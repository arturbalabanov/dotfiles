return {
    "rcarriga/nvim-notify",
    config = function()
        vim.notify = require("notify")
    end,
    lazy = false,
    keys = {
        {
            "<leader><leader>q",
            function()
                require("notify").dismiss({ silent = true })
            end,
            desc = "Dismiss all notifications",
        },
    },
}
