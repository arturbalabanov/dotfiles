local status_ok, lspsaga = pcall(require, "lspsaga")
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

my_utils.nkeymap("<leader>r", function() vim.cmd.Lspsaga("rename") end)
my_utils.nkeymap("<leader>a", function() vim.cmd.Lspsaga("code_action") end)
my_utils.nkeymap("gD", function() vim.cmd.Lspsaga("hover_doc") end)
