local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
    return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
    return
end

configs.setup {
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
                ["ib"] = "@block.inner",
                ["ab"] = "@block.outer",

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
            --     -- ['@parameter.outer'] = 'v', -- charwise
            --     -- ['@function.outer'] = 'V',  -- linewise
            --     -- ['@class.outer'] = '<c-v>', -- blockwise
            --
            --     ['@function.outer'] = 'V',
            --     ['@function.inner'] = 'V',
            --     ['@class.inner'] = 'V',
            --     ['@class.outer'] = 'V',
            --     ['@block.inner'] = 'V',
            --     ['@block.outer'] = 'V',
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
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
            },
        },
    },

    ensure_installed = "all",
    sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
    highlight = {
        enable = true,
    },
    autopairs = {
        enable = true,
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
}

-- ref: https://github.com/nvim-treesitter/nvim-treesitter/tree/master/queries

vim.treesitter.set_query("lua", "folds", [[
    (function_definition) @fold
]])

-- TODO: Add decorators
vim.treesitter.set_query("python", "folds", [[
    (function_definition) @fold
    (class_definition) @fold
]])

vim.treesitter.set_query("go", "folds", [[
    (function_declaration) @fold
    (method_declaration) @fold
    (type_declaration) @fold
]])

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

indent_blankline.setup {
    buftype_exclude = { "terminal" },
    show_current_context = true,
    -- show_current_context_start = true,
}
