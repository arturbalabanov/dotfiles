return {
    "beauwilliams/focus.nvim",
    opts = {
        enable = true,            -- Enable module
        commands = true,          -- Create Focus commands
        autoresize = {
            enable = true,        -- Enable or disable auto-resizing of splits
            width = 0,            -- Force width for the focused window
            height = 0,           -- Force height for the focused window
            minwidth = 0,         -- Force minimum width for the unfocused window
            minheight = 0,        -- Force minimum height for the unfocused window
            height_quickfix = 10, -- Set the height of quickfix panel
        },
        split = {
            bufnew = false, -- Create blank buffer for new split windows
            tmux = false,   -- Create tmux splits instead of neovim splits
        },
        ui = {
            number = false,                    -- Display line numbers in the focussed window only
            relativenumber = false,            -- Display relative line numbers in the focussed window only
            hybridnumber = true,               -- Display hybrid line numbers in the focussed window only
            absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

            cursorline = true,                 -- Display a cursorline in the focussed window only
            cursorcolumn = false,              -- Display cursorcolumn in the focussed window only
            colorcolumn = {
                enable = false,                -- Display colorcolumn in the foccused window only
                list = '+1',                   -- Set the comma-saperated list for the colorcolumn
            },
            signcolumn = false,                -- Display signcolumn in the focussed window only
            winhighlight = false,              -- Auto highlighting for focussed/unfocussed windows
        }
    },
    config = function(_, opts)
        require("focus").setup(opts)

        local focus_common = require("user.focus_common")

        local augroup = vim.api.nvim_create_augroup('UserFocusRules', { clear = true })

        vim.api.nvim_create_autocmd('WinEnter', {
            group = augroup,
            callback = function(opts)
                local bufnr = vim.api.nvim_get_current_buf()
                local winid = vim.api.nvim_get_current_win()

                require("ibl").setup_buffer(bufnr, { enabled = true })

                if focus_common.should_ignore_win(winid, "focus") then
                    vim.b.focus_disable = true
                    return
                end
            end,
        })

        vim.api.nvim_create_autocmd('WinLeave', {
            group = augroup,
            callback = function(opts)
                require("ibl").setup_buffer(opts.buf, { enabled = false })
            end,
        })

        vim.api.nvim_create_autocmd('FileType', {
            group = augroup,
            callback = function(_)
                local winid = vim.api.nvim_get_current_win()

                if focus_common.should_ignore_win(winid, "focus") then
                    vim.b.focus_disable = true
                    return
                end
            end,
        })

        -- By default, the highlight groups are setup as such:
        --   hi default link FocusedWindow VertSplit
        --   hi default link UnfocusedWindow Normal
        -- To change them, you can link them to a different highlight group, see `:h hi-default` for more info.
        --
        -- vim.cmd('hi link UnfocusedWindow CursorLine')
        -- vim.cmd('hi link FocusedWindow VisualNOS')
    end,
}
