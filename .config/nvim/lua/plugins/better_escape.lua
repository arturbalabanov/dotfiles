return {
    "max397574/better-escape.nvim",
    opts = {
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
}

-- -- create an autocmd for buffer enter to set the timeout length
-- vim.api.nvim_create_autocmd("BufEnter", {
--     callback = function()
--         require("utils.plugin").("better_escape")
--         require("better_escape").set_timeoutlen(vim.o.timeoutlen)
--     end,
-- })
