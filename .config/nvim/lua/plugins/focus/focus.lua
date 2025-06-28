local ignore_buftypes = {
    'nofile',
    'prompt',
    'popup',
    "help",
    "terminal",
}

local ignore_filetypes = {
    "help",
    "toggleterm",
    "neotest-output",
    "neotest-summary",
    "NvimTree",
    "TelescopePrompt",
    "DressingInput",
    "OverseerList",
    "Avante",
    "AvanteInput",
    "codecompanion",
    "dapui_breakpoints",
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "dap-repl",
    "dapui_console",
}

return {
    "beauwilliams/focus.nvim",
    opts = {
        enable = true,            -- Enable module
        commands = true,          -- Create Focus commands
        autoresize = {
            enable = false,       -- Enable or disable auto-resizing of splits
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
            number = true,                     -- Display line numbers in the focussed window only
            relativenumber = false,            -- Display relative line numbers in the focussed window only
            hybridnumber = false,              -- Display hybrid line numbers in the focussed window only
            absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

            cursorline = true,                 -- Display a cursorline in the focussed window only
            cursorcolumn = false,              -- Display cursorcolumn in the focussed window only
            colorcolumn = {
                enable = true,                 -- Display colorcolumn in the foccused window only
                list = '+1',                   -- Set the comma-saperated list for the colorcolumn
            },
            signcolumn = true,                 -- Display signcolumn in the focussed window only
            winhighlight = false,              -- Auto highlighting for focussed/unfocussed windows
        }
    },
    config = function(_, config_opts)
        require("focus").setup(config_opts)

        local augroup = vim.api.nvim_create_augroup('UserFocusRules', { clear = true })

        vim.api.nvim_create_autocmd('WinEnter', {
            group = augroup,
            callback = function(opts)
                local bufnr = vim.api.nvim_get_current_buf()

                require("ibl").setup_buffer(bufnr, { enabled = true })

                if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
                    vim.w.focus_disable = true
                else
                    vim.w.focus_disable = false
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
            callback = function(opts)
                if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
                    vim.b.focus_disable = true
                else
                    vim.b.focus_disable = false
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
