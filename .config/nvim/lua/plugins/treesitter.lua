local my_utils = require("user.utils")

return {
    {
        -- Config inspired by LazyVim
        -- ref: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua

        'nvim-treesitter/nvim-treesitter',
        event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        build = ":TSUpdate",
        init = function(plugin)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup.
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
        ---@type TSConfig
        opts = {
            auto_install = true,
            ensure_installed = "all",
            ignore_install = {},
            sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
            highlight = { enable = true },
            autopairs = { enable = true },
            context_commentstring = { enable = true, enable_autocmd = false },
            indent = { enable = true },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-n>",
                    node_incremental = "<C-n>",
                    scope_incremental = false,
                    node_decremental = "<C-p>",
                },
            },

            textobjects = {
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ic"] = "@class.inner",
                        ["ac"] = "@class.outer",
                        ["iB"] = "@block.inner",
                        ["aB"] = "@block.outer",

                        -- You can also use captures from other query groups like `locals.scm`
                        -- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                    },
                    -- You can choose the select mode (default is charwise 'v')
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * method: eg 'v' or 'o'
                    -- and should return the mode ('v', 'V', or '<c-v>') or a table
                    -- mapping query_strings to modes.
                    -- selection_modes = {
                    --   -- ['@parameter.outer'] = 'v', -- charwise
                    --   -- ['@function.outer'] = 'V',  -- linewise
                    --   -- ['@class.outer'] = '<c-v>', -- blockwise
                    --
                    --   ['@function.outer'] = 'V',
                    --   ['@function.inner'] = 'V',
                    --   ['@class.inner'] = 'V',
                    --   ['@class.outer'] = 'V',
                    --   ['@block.inner'] = 'V',
                    --   ['@block.outer'] = 'V',
                    -- },
                    -- If you set this to `true` (default is `false`) then any textobject is
                    -- extended to include preceding or succeeding whitespace. Succeeding
                    -- whitespace has priority in order to act similarly to eg the built-in
                    -- `ap`.
                    --
                    -- Can also be a function which gets passed a table with the keys
                    -- * query_string: eg '@function.inner'
                    -- * selection_mode: eg 'v'
                    -- and should return true of false
                    -- include_surrounding_whitespace = true,
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer",
                        ["]C"] = "@class.outer",
                        ["]A"] = "@parameter.inner",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                        ["[A"] = "@parameter.inner",
                    },
                },
            },
        },
        keys = {
            { "<C-n>", desc = "Increment Selection" },
            { "<C-p>", desc = "Decrement Selection", mode = "x" },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "VeryLazy",
        enabled = true,
        config = function()
            -- config stolen from LazyVim
            -- ref: https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/treesitter.lua#L95

            -- If treesitter is already loaded, we need to run config again for textobjects
            if my_utils.plugin_is_loaded("nvim-treesitter") then
                local opts = my_utils.get_plugin_opts("nvim-treesitter")
                require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects }) ---@diagnostic disable-line: missing-fields
            end

            -- When in diff mode, we want to use the default
            -- vim text objects c & C instead of the treesitter ones.
            local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
            local configs = require("nvim-treesitter.configs")
            for name, fn in pairs(move) do
                if name:find("goto") == 1 then
                    move[name] = function(q, ...)
                        if vim.wo.diff then
                            local config = configs.get_module("textobjects.move")[name]
                            for key, query in pairs(config or {}) do
                                if q == query and key:find("[%]%[][cC]") then
                                    vim.cmd("normal! " .. key)
                                    return
                                end
                            end
                        end
                        return fn(q, ...)
                    end
                end
            end
        end,
    },
}
