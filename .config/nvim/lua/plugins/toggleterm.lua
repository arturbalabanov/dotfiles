return {
    "akinsho/toggleterm.nvim",
    version = '*',
    -- enabled = vim.g.neovide,
    opts = {
        direction = 'vertical',
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        shade_terminals = false,
    },
    keys = {
        { [[<C-\>]], function() vim.cmd.ToggleTermToggleAll() end, desc = "Toggle Terminals" },
        {
            [[ <C-S-\> ]],
            function()
                vim.cmd.ToggleTermToggleAll()
                require('toggleterm.terminal').Terminal:new():open()
            end,
            desc = "Open a new terminal"
        },
    },
}

-- vim.api.nvim_create_autocmd("TermOpen", {
--     group = vim.api.nvim_create_augroup('UserFileTypeSpecificOptions', { clear = true }),
--     pattern = 'term://*toggleterm#*',
--     callback = function(opts)
--         local keymap_opts = { buffer = opts.buffer }
--
--         my_utils.tkeymap([[<C-\>]], vim.cmd.ToggleTerm, keymap_opts)
--         my_utils.tkeymap('<S-CR>', function() Terminal:new():open() end, keymap_opts)
--
--         -- Esc to normal mode (of the buffer as oposed to the shell)
--         my_utils.tkeymap('<Esc>', [[<C-\><C-n>]], keymap_opts)
--
--         my_utils.tnkeymap("gh", function() vim.cmd.wincmd("h") end)
--         my_utils.tnkeymap("gj", function() vim.cmd.wincmd("j") end)
--         my_utils.tnkeymap("gk", function() vim.cmd.wincmd("k") end)
--         my_utils.tnkeymap("gl", function() vim.cmd.wincmd("l") end)
--         my_utils.tnkeymap("K", vim.cmd.tabn)
--         my_utils.tnkeymap("J", vim.cmd.tabp)
--     end
-- })
