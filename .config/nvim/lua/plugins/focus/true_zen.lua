return {
    "Pocco81/true-zen.nvim",
    opts = {
        modes = {
            -- configurations per mode
            ataraxis = {
                shade = "dark", -- if `dark` then dim the padding windows, otherwise if it's `light` it'll brighten said windows
                backdrop = 0,   -- percentage by which padding windows should be dimmed/brightened. Must be a number between 0 and 1. Set to 0 to keep the same background color
                minimum_writing_area = {
                    -- minimum size of main window
                    width = 70,
                    height = 44,
                },
                quit_untoggles = true, -- type :q or :qa to quit Ataraxis mode
                padding = {
                    -- padding windows
                    left = 52,
                    right = 52,
                    top = 0,
                    bottom = 0,
                },
                callbacks = {
                    open_pre = nil,
                    open_pos = function()
                        vim.api.nvim_win_set_option(0, "number", false)
                        vim.api.nvim_win_set_option(0, "relativenumber", false)

                        require("true-zen.integrations.tmux").on()
                        require("user.utils").kitty.send_cmd("set-font-size", "+5")
                    end,
                    close_pre = nil,
                    close_pos = function()
                        vim.api.nvim_win_set_option(0, "number", true)
                        vim.api.nvim_win_set_option(0, "relativenumber", true)

                        require("true-zen.integrations.tmux").off()
                        require("user.utils").kitty.send_cmd("set-font-size", "-5")
                    end
                },
            },
            minimalist = {
                ignored_buf_types = { "nofile" }, -- save current options from any window except ones displaying these kinds of buffers
                options = {
                    -- options to be disabled when entering Minimalist mode
                    number = false,
                    relativenumber = false,
                    showtabline = 0,
                    signcolumn = "no",
                    statusline = "",
                    cmdheight = 1,
                    laststatus = 0,
                    showcmd = false,
                    showmode = false,
                    ruler = false,
                    numberwidth = 1
                },
                callbacks = {
                    -- run functions when opening/closing Minimalist mode
                    open_pre = nil,
                    open_pos = nil,
                    close_pre = nil,
                    close_pos = nil
                },
            },
            narrow = {
                --- change the style of the fold lines. Set it to:
                --- `informative`: to get nice pre-baked folds
                --- `invisible`: hide them
                --- function() end: pass a custom func with your fold lines. See :h foldtext
                folds_style = "informative",
                run_ataraxis = true, -- display narrowed text in a Ataraxis session
                callbacks = {
                    -- run functions when opening/closing Narrow mode
                    open_pre = nil,
                    open_pos = nil,
                    close_pre = nil,
                    close_pos = nil
                },
            },
            focus = {
                callbacks = {
                    -- run functions when opening/closing Focus mode
                    open_pre = nil,
                    open_pos = nil,
                    close_pre = nil,
                    close_pos = nil
                },
            }
        },
        integrations = {
            tmux = true, -- hide tmux status bar in (minimalist, ataraxis)
            kitty = {
                -- NOTE: this is a bit buggy and not very customizable, so I
                -- disabled it and implemented it myself

                -- increment font size in Kitty. Note: you must set `allow_remote_control socket-only` and `listen_on unix:/tmp/kitty` in your personal config (ataraxis)
                enabled = false,
                font = "+5"
            },
            twilight = false, -- enable twilight (ataraxis)
            lualine = false   -- hide nvim-lualine (ataraxis)
        },
    }
}
