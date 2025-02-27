local my_utils = require("user.utils")

-- Use Space as a leader key
vim.g.mapleader = ' '

my_utils.nkeymap(";", ":", { silent = false })

-- Use vv to select current line without leading and trailing indentation
my_utils.nkeymap("vv", "^vg_")

-- Reselect visual block after indent/dedent
my_utils.vkeymap("<", "<gv")
my_utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
my_utils.nkeymap("H", "^")
my_utils.vkeymap("H", "^")
my_utils.nkeymap("L", "$")
my_utils.vkeymap("L", "g_")

-- Redo with Shift + U (opposite of undo - u), frees up C-r for something else
-- This just makes more sense - inspired by Helix :)
my_utils.nkeymap("U", vim.cmd.redo)

-- -- Toggle quickfix window with <F1>
-- my_utils.nkeymap("<F1>", function()
--     if vim.api.nvim_buf_get_option(0, "filetype") == "qf" then
--         vim.cmd.cclose()
--     else
--         vim.cmd.copen()
--     end
-- end)

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
my_utils.nkeymap("<F2>", toggle_file_tree)
my_utils.ikeymap("<F2>", function() 
    vim.cmd.stopinsert() 
    toggle_file_tree()
end)


-- Toggle the line numbers with <F6>
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
end)

-- Clear highlight search with ,/
my_utils.nkeymap(",/", vim.cmd.nohlsearch)

-- Move between tabs (for windows -- see tmux.lua)
my_utils.nkeymap("<C-l>", vim.cmd.tabn)
my_utils.nkeymap("<C-h>", vim.cmd.tabp)

my_utils.nkeymap("<C-u>", "gUiw")
my_utils.ikeymap("<C-u>", "<C-o>gUiw")

my_utils.nkeymap("<C-e>", vim.cmd.Inspect)

-- Move a window to a new tab
my_utils.nkeymap("<C-t>", "<C-w>T")

-- Move a window to a split bellow
my_utils.nkeymap("<C-w>j", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.split()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_height(0, 20)
end)

-- Move a window to a split right
my_utils.nkeymap("<C-w>l", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.vsplit()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_width(0, 60)
end)


-- Select last pasted text with gV
my_utils.nkeymap("gV", "`[V`]")

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
my_utils.nkeymap("[b", vim.cmd.bprev)
my_utils.nkeymap("]b", vim.cmd.bnext)
