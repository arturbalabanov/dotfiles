local keymap = require("utils.keymap")
local utils = require("utils")
local plugin_utils = require("utils.plugin")

-- NOTE: Diagnostics keymaps are now in user/diagnostic.lua

-- Use Space as the leader key and comma as the localleader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

keymap.set_n(";", ":", { silent = false, desc = "Enter command mode" })

keymap.set_n("vv", "^vg_", { desc = "Select current line (excl. leading whitespace)" })

local temp_disable_smart_indent = function(callback)
    if type(callback) == "string" then
        -- NOTE: Need to save `callback` to a local variable to avoid recursion in the function bellow
        local keys = callback
        callback = function()
            vim.cmd.normal({ keys, bang = true })
        end
    end

    if type(callback) ~= "function" then
        error("temp_disable_smart_indent: callback must be a function or a string")
    end

    return function()
        local orig_smartindent = vim.api.nvim_get_option_value("smartindent", { buf = 0 })
        if orig_smartindent then
            vim.api.nvim_set_option_value("smartindent", false, { buf = 0 })
            vim.bo.smartindent = false
        end

        callback()

        vim.api.nvim_set_option_value("smartindent", orig_smartindent, { buf = 0 })
    end
end

keymap.set_n(">>", temp_disable_smart_indent(">>"), { desc = "Indent line" })
keymap.set_v("<", "<gv", { desc = "Reselect visual block after indent" })
keymap.set_v(">", temp_disable_smart_indent(">gv"), { desc = "Reselect visual block after dedent" })

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

-- keymap.set_n("<C-w>j", function()
--     local winnr = vim.api.nvim_get_current_win()
--     vim.cmd.split()
--     vim.api.nvim_win_close(winnr, false)
--
--     vim.api.nvim_win_set_height(0, 20)
-- end, { desc = "Move window to split below" })
--
-- keymap.set_n("<C-w>l", function()
--     local winnr = vim.api.nvim_get_current_win()
--     vim.cmd.vsplit()
--     vim.api.nvim_win_close(winnr, false)
--
--     vim.api.nvim_win_set_width(0, 60)
-- end, { desc = "Move window to split right" })

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
keymap.set_i(
    "<S-Enter>",
    '""<Esc>m`2F"i(<Esc>4f"a)<Esc>``a<CR><Esc>la',
    { desc = "Break python string into multiple lines" }
)

keymap.set_n("[b", vim.cmd.bprev, { desc = "Previous buffer" })
keymap.set_n("]b", vim.cmd.bnext, { desc = "Next buffer" })

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

keymap.set_x("/", "<C-\\><C-n>`</\\%V", { desc = "Search forward within visual selection" })
keymap.set_x("?", "<C-\\><C-n>`>?\\%V", { desc = "Search backward within visual selection" })

keymap.set_n("<leader><leader>t", function()
    vim.cmd.tabnew()
    vim.cmd.Telescope("buffers")
end, { desc = "open new tab " })

local get_current_position = function(opts)
    opts = utils.apply_defaults(opts, {
        winnr = 0,
        include_line = false,
        include_column = false,
        substitute_home = true,
    })

    local bufnr = vim.api.nvim_win_get_buf(opts.winnr)
    local position = vim.api.nvim_buf_get_name(bufnr)

    if opts.substitute_home then
        position = position:gsub(vim.env.HOME, "~")
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(opts.winnr))

    if opts.include_line then
        position = string.format("%s:%d", position, row)
    end

    if opts.include_column then
        position = string.format("%s:%d", position, col + 1)
    end

    return position
end

keymap.set_n("<leader><leader>y", function()
    local position = get_current_position()
    vim.fn.setreg("+", position)
    require("notify").notify(
        position,
        vim.log.levels.INFO,
        { title = "copied", render = "compact", stages = "slide_in_slide_out" }
    )
end, { desc = "copy the filepath of the current buffer" })

keymap.set_n("<leader><leader>Y", function()
    local position = get_current_position({ include_line = true, include_column = true })
    vim.fn.setreg("+", position)
    require("notify").notify(
        position,
        vim.log.levels.INFO,
        { title = "copied", render = "compact", stages = "slide_in_slide_out" }
    )
end, { desc = "copy the filepath of the current buffer and cursor position" })

keymap.set_n("<leader>lh", function()
    local buf = vim.api.nvim_get_current_buf()
    local lsp_clients = vim.lsp.get_clients({ bufnr = buf })

    local success = false

    for _, client in pairs(lsp_clients) do
        if client.server_capabilities.inlayHintProvider or client:supports_method("textDocument/inlayHint", buf) then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            success = true
        end
    end

    if not success then
        utils.simple_notify("No LSP client with inlay hint support found", "warn")
    end
end, { desc = "LSP: Toggle Inlay Hints" })
