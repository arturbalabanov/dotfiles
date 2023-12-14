local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
    return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
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
            },
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
            },
            goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
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
-- refs:
--   https://www.reddit.com/r/neovim/comments/16xz3q9/treesitter_highlighted_folds_are_now_in_neovim/
--   https://www.reddit.com/r/neovim/comments/16sqyjz/finally_we_can_have_highlighted_folds/
--   https://github.com/Wansmer/nvim-config/blob/2f4badacf08c648b8a79415a433ec2f0fcb19905/lua/modules/foldtext.lua

-- local function parse_fold_range(start_linenr, end_linenr)
--     local bufnr = vim.api.nvim_get_current_buf()
--
--     local line = vim.api.nvim_buf_get_lines(bufnr, start_linenr - 1, end_linenr, false)[1]
--     if not line then
--         return nil
--     end
--
--     local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
--     if not ok then
--         return nil
--     end
--
--     local query = vim.treesitter.query.get(parser:lang(), 'highlights')
--     if not query then
--         return nil
--     end
--
--     local tree = parser:parse({ start_linenr - 1, end_linenr })[1]
--
--     local result = {}
--
--     local line_pos = 0
--
--     for id, node, metadata in query:iter_captures(tree:root(), 0, start_linenr - 1, end_linenr) do
--         local name = query.captures[id]
--         local start_row, start_col, end_row, end_col = node:range()
--
--         local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)
--
--         if start_row == end_linenr - 1 and end_row == end_linenr - 1 then
--             -- check for characters ignored by treesitter
--             if start_col > line_pos then
--                 table.insert(result, {
--                     line:sub(line_pos + 1, start_col),
--                     { { 'Folded', priority } },
--                     range = { line_pos, start_col },
--                 })
--             end
--             line_pos = end_col
--
--             local text = line:sub(start_col + 1, end_col)
--             table.insert(result, { text, { { '@' .. name, priority } }, range = { start_col, end_col } })
--         end
--     end
--
--     -- local i = 1
--     -- while i <= #result do
--     --     -- find first capture that is not in current range and apply highlights on the way
--     --     local j = i + 1
--     --     while j <= #result and result[j].range[1] >= result[i].range[1] and result[j].range[2] <= result[i].range[2] do
--     --         for k, v in ipairs(result[i][2]) do
--     --             if not vim.tbl_contains(result[j][2], v) then
--     --                 table.insert(result[j][2], k, v)
--     --             end
--     --         end
--     --         j = j + 1
--     --     end
--     --
--     --     -- remove the parent capture if it is split into children
--     --     if j > i + 1 then
--     --         table.remove(result, i)
--     --     else
--     --         -- highlights need to be sorted by priority, on equal prio, the deeper nested capture (earlier
--     --         -- in list) should be considered higher prio
--     --         if #result[i][2] > 1 then
--     --             table.sort(result[i][2], function(a, b)
--     --                 return a[2] < b[2]
--     --             end)
--     --         end
--     --
--     --         result[i][2] = vim.tbl_map(function(tbl)
--     --             return tbl[1]
--     --         end, result[i][2])
--     --         result[i] = { result[i][1], result[i][2] }
--     --
--     --         i = i + 1
--     --     end
--     -- end
--
--     return result
-- end
--
-- function CustomFoldText()
--     local result = parse_fold_range(vim.v.foldstart, vim.v.foldend)
--     if not result then
--         return vim.fn.foldtext()
--     end
--
--     local folded = {
--         { ' ',                                             'FoldedIcon' },
--         { '+' .. vim.v.foldend - vim.v.foldstart .. ' lines', 'FoldedText' },
--         { ' ',                                             'FoldedIcon' },
--     }
--
--     for _, item in ipairs(folded) do
--         table.insert(result, item)
--     end
--
--     -- local result2 = parse_line(vim.v.foldend)
--     -- if result2 then
--     --     local first = result2[1]
--     --     result2[1] = { vim.trim(first[1]), first[2] }
--     --     for _, item in ipairs(result2) do
--     --         table.insert(result, item)
--     --     end
--     -- end
--
--
--     return table.concat(vim.tbl_map(function(item) return item[1] end, result), "")
-- end
--
-- ParseFoldRange = parse_fold_range -- TODO: Remove me, used only for debugging

-- ref: https://github.com/nvim-treesitter/nvim-treesitter/tree/master/queries

vim.treesitter.query.set("lua", "folds", [[
  (function_definition) @fold
  (function_declaration) @fold
]])

vim.treesitter.query.set("python", "folds", [[
  (decorated_definition) @fold
  (function_definition) @fold
  (class_definition) @fold
]])

vim.treesitter.query.set("go", "folds", [[
  (function_declaration) @fold
  (method_declaration) @fold
  (type_declaration) @fold
]])

-- ref: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
    callback = function()
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
    end
})
