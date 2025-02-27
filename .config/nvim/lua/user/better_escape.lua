local my_utils = require("user.utils")

local status_ok, better_escape = pcall(require, "better_escape")
if not status_ok then
    my_utils.ikeymap("jj", "<Esc>")
    my_utils.simple_notify("cannot import better_escape.nvim ", "error")

    return
end

better_escape.setup {
    timeout = vim.o.timeoutlen,
    default_mappings = false,
    mappings = {
        i = {
            j = {
                j = "<Esc>",
            },
            k = {
                k = "<Esc>",
            },
        },
    }
}
