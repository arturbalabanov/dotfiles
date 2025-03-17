local my_utils = require("user.utils")

-- Use Space as the leader key and comma as the localleader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

my_utils.nkeymap(";", ":", { silent = false }, { desc = "Enter command mode" })

my_utils.nkeymap("vv", "^vg_", { desc = "Select current line (excl. leading whitespace)" })

my_utils.vkeymap("<", "<gv", { desc = "Reselect visual block after indent" })
my_utils.vkeymap(">", ">gv", { desc = "Reselect visual block after dedent" })

-- Easily go to the beginning/end of the line
my_utils.nkeymap("H", "^", { desc = "Move to beginning of line" })
my_utils.vkeymap("H", "^", { desc = "Move to beginning of line" })
my_utils.nkeymap("L", "$", { desc = "Move to end of line" })
my_utils.vkeymap("L", "g_", { desc = "Move to end of line" })

-- Redo with Shift + U (opposite of undo - u), frees up C-r for something else
-- This just makes more sense - inspired by Helix :)
my_utils.nkeymap("U", vim.cmd.redo, { desc = "Redo" })

-- -- Toggle quickfix window with <F1>
-- my_utils.nkeymap("<F1>", function()
--     if vim.api.nvim_buf_get_option(0, "filetype") == "qf" then
--         vim.cmd.cclose()
--     else
--         vim.cmd.copen()
--     end
-- end, { desc = "Toggle quickfix window" })

-- Toggle nvim-tree (or diffview if in diff mode) with <F2>
local toggle_file_tree = function()
    local diff_mode = vim.opt_local.diff:get()

    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    if diff_mode or filetype == "DiffviewFiles" then
        vim.cmd.DiffviewToggleFiles()
        return
    end

    vim.cmd.NvimTreeToggle()
end
my_utils.nkeymap("<F2>", toggle_file_tree, { desc = "Toggle file tree" })
my_utils.ikeymap("<F2>", function()
    vim.cmd.stopinsert()
    toggle_file_tree()
end, { desc = "Toggle file tree" })


my_utils.nkeymap("<F6>", function()
    local ignore_fts = { "NvimTree", "OverseerList", "neotest-summary", "toggleterm" }

    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    if vim.tbl_contains(ignore_fts, filetype) then
        return
    end

    for _, opt in pairs({ "number", "relativenumber" }) do
        local curr_val = vim.api.nvim_win_get_option(win, opt)
        vim.api.nvim_win_set_option(win, opt, not curr_val)
    end
end, { desc = "Toggle line numbers" })

my_utils.nkeymap(",/", vim.cmd.nohlsearch, { desc = "Clear search highlight" })

my_utils.nkeymap("<C-l>", vim.cmd.tabn, { desc = "Next tab" })
my_utils.nkeymap("<C-h>", vim.cmd.tabp, { desc = "Previous tab" })

my_utils.nkeymap("<C-u>", "gUiw", { desc = "Uppercase word under cursor" })
my_utils.ikeymap("<C-u>", "<C-o>gUiw", { desc = "Uppercase word under cursor" })

my_utils.nkeymap("<C-e>", vim.cmd.Inspect, { desc = "Inspect word under cursor" })

my_utils.nkeymap("<C-t>", "<C-w>T", { desc = "Move window to new tab" })

my_utils.nkeymap("<C-w>j", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.split()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_height(0, 20)
end, { desc = "Move window to split below" })

my_utils.nkeymap("<C-w>l", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.vsplit()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_width(0, 60)
end, { desc = "Move window to split right" })


my_utils.nkeymap("gV", "`[V`]", { desc = "Select last pasted text" })

-- Break string into multiple lines (Python)
-- Super ugly and error prone but gets the job done for now
-- Best to use a treesitter transformation
--
-- variable = "some text |some more text"
-- variable = (
--     "some text "
--     "|some more text"
-- )
my_utils.ikeymap("<S-Enter>", "\"\"<Esc>m`2F\"i(<Esc>4f\"a)<Esc>``a<CR><Esc>la")

-- Move between buffers with [b and ]b
my_utils.nkeymap("[b", vim.cmd.bprev, { desc = "Previous buffer" })
my_utils.nkeymap("]b", vim.cmd.bnext, { desc = "Next buffer" })

my_utils.nkeymap("<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
my_utils.nkeymap("[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
my_utils.nkeymap("]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
