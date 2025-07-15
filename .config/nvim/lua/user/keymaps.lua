local keymap = require("utils.keymap")
local utils = require("utils")
local plugin_utils = require("utils.plugin")

-- Use Space as the leader key and comma as the localleader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

keymap.set_n(";", ":", { silent = false }, { desc = "Enter command mode" })

keymap.set_n("vv", "^vg_", { desc = "Select current line (excl. leading whitespace)" })

keymap.set_v("<", "<gv", { desc = "Reselect visual block after indent" })
keymap.set_v(">", ">gv", { desc = "Reselect visual block after dedent" })

-- Easily go to the beginning/end of the line
keymap.set_n("H", "^", { desc = "Move to beginning of line" })
keymap.set_v("H", "^", { desc = "Move to beginning of line" })
keymap.set_n("L", "$", { desc = "Move to end of line" })
keymap.set_v("L", "g_", { desc = "Move to end of line" })

-- Redo with Shift + U (opposite of undo - u), frees up C-r for something else
-- This just makes more sense - inspired by Helix :)
keymap.set_n("U", vim.cmd.redo, { desc = "Redo" })

local toggle_oil_ssh_tree = function()
    local nvim_tree_opts = plugin_utils.get_opts("nvim-tree.lua")
    local nvim_tree_width = utils.get(nvim_tree_opts, "view", "width")
    local file_tree_width = nvim_tree_width or 30

    local is_oil_ssh_tree = utils.get_var_or_default("oil_ssh_tree", false, { win = 0 })

    if is_oil_ssh_tree then
        -- If already in oil ssh tree, close it
        vim.api.nvim_win_close(0, false) -- force: false
        return
    end

    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

    if filetype == "oil" then
        -- editing a directory with oil, so opening an oil filetree wouldn't make much sense here
        -- default to nvim-tree

        vim.cmd.NvimTreeToggle()
        return
    end

    vim.cmd("vertical leftabove Oil")
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_var(win, "oil_ssh_tree", true)
    -- TODO: some duplication with focus.nvim and similar plugins, see if we can reuse it by e.g. setting the buffer type,
    --       filetype or just the window local variable we're using here
    vim.api.nvim_win_set_width(win, file_tree_width)
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
end

local toggle_file_tree = function()
    -- Toggle nvim-tree (or diffview if in diff mode, or oil if editing a remote file using oil-ssh://)
    local diff_mode = vim.opt_local.diff:get()

    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

    if diff_mode or filetype == "DiffviewFiles" then
        vim.cmd.DiffviewToggleFiles()
        return
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename:match("^oil%-ssh://") then
        toggle_oil_ssh_tree()
        return
    end

    vim.cmd.NvimTreeToggle()
end
keymap.set_n("<F2>", toggle_file_tree, { desc = "Toggle file tree" })
keymap.set_i("<F2>", function()
    vim.cmd.stopinsert()
    toggle_file_tree()
end, { desc = "Toggle file tree" })


keymap.set_n("<F6>", function()
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

keymap.set_n(",/", vim.cmd.nohlsearch, { desc = "Clear search highlight" })

keymap.set_n("<C-l>", vim.cmd.tabn, { desc = "Next tab" })
keymap.set_n("<C-h>", vim.cmd.tabp, { desc = "Previous tab" })

-- TODO: replace with this plugin https://github.com/johmsalas/text-case.nvim
-- TODO: Maybe better mapping would be gcu to lowercase. or maybe use a motion and make this an operator, e.g. gcuiw
keymap.set_n("<C-u>", "gUiw", { desc = "Uppercase word under cursor" })
keymap.set_i("<C-u>", "<C-o>gUiw", { desc = "Uppercase word under cursor" })

keymap.set_n("<C-e>", vim.cmd.Inspect, { desc = "Inspect word under cursor" })

keymap.set_n("<C-t>", "<C-w>T", { desc = "Move window to new tab" })

keymap.set_n("<C-w>j", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.split()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_height(0, 20)
end, { desc = "Move window to split below" })

keymap.set_n("<C-w>l", function()
    local winnr = vim.api.nvim_get_current_win()
    vim.cmd.vsplit()
    vim.api.nvim_win_close(winnr, false)

    vim.api.nvim_win_set_width(0, 60)
end, { desc = "Move window to split right" })


keymap.set_n("gV", "`[V`]", { desc = "Select last pasted text" })

-- TODO: Refactor this to use treesitter and move to after/plugin/python (as a buffer-local keymap too)
-- Break string into multiple lines (Python)
-- Super ugly and error prone but gets the job done for now
-- Best to use a treesitter transformation
--
-- variable = "some text |some more text"
-- variable = (
--     "some text "
--     "|some more text"
-- )
keymap.set_i("<S-Enter>", "\"\"<Esc>m`2F\"i(<Esc>4f\"a)<Esc>``a<CR><Esc>la",
    { desc = "Break python string into multiple lines" })

keymap.set_n("[b", vim.cmd.bprev, { desc = "Previous buffer" })
keymap.set_n("]b", vim.cmd.bnext, { desc = "Next buffer" })

keymap.set_n("<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap.set_n("[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set_n("]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

keymap.set_n("<C-q>", function()
    local buf_filetype = vim.api.nvim_buf_get_option(0, "filetype")

    if buf_filetype == "TelescopePrompt" then
        require("telescope.actions").smart_send_to_qflist()
        vim.cmd.copen()
    elseif buf_filetype == "qf" then
        vim.cmd.cclose()
    else
        vim.cmd.copen()
    end
end, { desc = "Toggle quickfix window" })

keymap.set_n("[q", vim.cmd.cprev, { desc = "Previous quickfix item" })
keymap.set_n("]q", vim.cmd.cnext, { desc = "Next quickfix item" })

keymap.set_x('/', '<C-\\><C-n>`</\\%V', { desc = 'Search forward within visual selection' })
keymap.set_x('?', '<C-\\><C-n>`>?\\%V', { desc = 'Search backward within visual selection' })
