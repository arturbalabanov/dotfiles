return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile", "BufWritePre", "BufEnter" },
        opts = {
            signs                           = {
                add          = { text = '│' },
                change       = { text = '│' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            signcolumn                      = false, -- Toggle with `:Gitsigns toggle_signs`
            numhl                           = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl                          = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff                       = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir                    = {
                interval = 1000,
                follow_files = true
            },
            attach_to_untracked             = true,
            current_line_blame              = false,
            current_line_blame_opts         = {
                virt_text = true,
                virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
                virt_text_priority = 1,
                delay = 300,
                ignore_whitespace = true,
            },
            current_line_blame_formatter    = '<author>, <author_time:%R>: <abbrev_sha> ', -- %R: relative time
            -- current_line_blame_formatter_nc = 'Not comitted yet ',
            current_line_blame_formatter_nc = '',
            sign_priority                   = 6,
            update_debounce                 = 100,
            status_formatter                = nil,   -- Use default
            max_file_length                 = 40000, -- Disable if file is longer than this (in lines)
            preview_config                  = {
                -- Options passed to nvim_open_win
                border = 'single',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
            _on_attach_pre                  = function(bufnr, callback)
                if vim.fn.executable("yadm") == 1 then
                    require("gitsigns-yadm").yadm_signs(callback, { bufnr = bufnr })
                else
                    -- if optionally disabling the plugin, make sure to call
                    -- 'callback' with no arguments
                    callback()
                end
            end,
        },
        keys = {
            { '[g',         function() require("gitsigns").nav_hunk('prev') end, desc = "Jump to previous git hunk" },
            { ']g',         function() require("gitsigns").nav_hunk('next') end, desc = "Jump to next git hunk" },
            { '<leader>gs', function() require("gitsigns").toggle_signs() end,   desc = "Toggle git signs" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "purarue/gitsigns-yadm.nvim",
                opts = {
                    yadm_repo_git = vim.fn.expand("~/.local/share/yadm/repo.git"),
                    disable_inside_gitdir = false,
                    shell_timeout_ms = 1000,
                },
            },
        },
    },
}
