local status_ok, lspsaga = pcall(require, "lspsaga")
if not status_ok then
    return
end

local my_utils = require("user.utils")

lspsaga.setup {
    lightbulb = {
        enable = true,
        sign = false,
        virtual_text = true,
    },
    symbol_in_winbar = {
        enable = false,
    },
    rename = {
        keys = {
            quit = { "<Esc>", "<C-c>" },
            exec = "<CR>",
        },
    },
}

my_utils.nkeymap("<leader>r", { vim.cmd.Lspsaga, "rename" })
my_utils.nkeymap("<leader>a", { vim.cmd.Lspsaga, "code_action" })
