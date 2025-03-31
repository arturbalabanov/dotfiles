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
--         local keymap = require('utils.keymap')
--
--         keymap.set_t([[<C-\>]], vim.cmd.ToggleTerm, keymap_opts)
--         keymap.set_t('<S-CR>', function() Terminal:new():open() end, keymap_opts)
--
--         -- Esc to normal mode (of the buffer as oposed to the shell)
--         keymap.set_t('<Esc>', [[<C-\><C-n>]], keymap_opts)
--
--         keymap.set_tn("gh", function() vim.cmd.wincmd("h") end)
--         keymap.set_tn("gj", function() vim.cmd.wincmd("j") end)
--         keymap.set_tn("gk", function() vim.cmd.wincmd("k") end)
--         keymap.set_tn("gl", function() vim.cmd.wincmd("l") end)
--         keymap.set_tn("K", vim.cmd.tabn)
--         keymap.set_tn("J", vim.cmd.tabp)
--     end
-- })
