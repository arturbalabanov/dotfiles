local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    return
end

local utils    = require('user.utils')
local Terminal = require('toggleterm.terminal').Terminal

toggleterm.setup({
    direction = 'vertical',

    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    shade_terminals = false,
})

utils.nkeymap([[<C-\>]], vim.cmd.ToggleTermToggleAll)
utils.nkeymap('<S-CR>', function()
    vim.cmd.ToggleTermToggleAll()
    Terminal:new():open()
end)

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup('UserFileTypeSpecificOptions', { clear = true }),
    pattern = 'term://*toggleterm#*',
    callback = function(opts)
        local keymap_opts = { buffer = opts.buffer }

        utils.tkeymap([[<C-\>]], vim.cmd.ToggleTerm, keymap_opts)
        utils.tkeymap('<S-CR>', function() Terminal:new():open() end, keymap_opts)

        -- Esc to normal mode (of the buffer as oposed to the shell)
        utils.tkeymap('<Esc>', [[<C-\><C-n>]], keymap_opts)

        -- utils.tnkeymap("gh", [[execute wincmd h]])
        -- utils.tnkeymap("gj", [[<C-\><C-n>:wincmd j<CR>]])
        -- utils.tnkeymap("gk", [[<C-\><C-n>:wincmd k<CR>]])
        -- utils.tnkeymap("gl", [[<C-\><C-n>:wincmd l<CR>]])
        -- utils.tnkeymap("K", [[<C-\><C-n>:tabn<CR>]])
        -- utils.tnkeymap("J", [[<C-\><C-n>:tabp<CR>]])
        utils.tnkeymap("gh", function() vim.cmd.wincmd("h") end)
        -- utils.tnkeymap("gj", function() vim.cmd.wincmd("j") end)
        -- utils.tnkeymap("gk", function() vim.cmd.wincmd("k") end)
        -- utils.tnkeymap("gl", function() vim.cmd.wincmd("l") end)
        -- utils.tnkeymap("K", vim.cmd.tabn)
        -- utils.tnkeymap("J", vim.cmd.tabp)
    end
})
