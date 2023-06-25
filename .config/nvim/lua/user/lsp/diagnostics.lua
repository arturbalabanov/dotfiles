local my_utils = require("user.utils")

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

my_utils.nkeymap("<leader>e", vim.diagnostic.open_float)
my_utils.nkeymap("[d", vim.diagnostic.goto_prev)
my_utils.nkeymap("]d", vim.diagnostic.goto_next)
