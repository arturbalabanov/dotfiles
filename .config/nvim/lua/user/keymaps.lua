local my_utils = require("user.utils")

-- Use Space as a leader key
vim.g.mapleader = ' '

my_utils.ikeymap("jj", "<Esc>")
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

-- Toggle folds with <Tab>
my_utils.nkeymap("<Tab>", "za")

-- Toggle the line numbers with <F1>
my_utils.nkeymap("<F1>", function()
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

my_utils.nkeymap("<F2>", function()
    local diff_mode = vim.opt_local.diff:get()

    local win = vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    if diff_mode or filetype == "DiffviewFiles" then
        vim.cmd.DiffviewToggleFiles()
        return
    end

    vim.cmd.NvimTreeToggle()
end)

-- Clear highlight search with ,/
my_utils.nkeymap(",/", vim.cmd.nohlsearch)

-- Move between windows and tabs
my_utils.nkeymap("gh", { vim.cmd.wincmd, "h" })
my_utils.nkeymap("gj", { vim.cmd.wincmd, "j" })
my_utils.nkeymap("gk", { vim.cmd.wincmd, "k" })
my_utils.nkeymap("gl", { vim.cmd.wincmd, "l" })
my_utils.nkeymap("K", vim.cmd.tabn)
my_utils.nkeymap("J", vim.cmd.tabp)

my_utils.nkeymap("<C-u>", "gUiw")
my_utils.ikeymap("<C-u>", "<C-o>gUiw")

-- TODO: Replace with vim.cmd.Inspect when updating to neovim 0.9
my_utils.nkeymap("<C-e>",
    function()
        local win = vim.api.nvim_get_current_win()
        local row, col = vim.api.nvim_win_get_cursor(win)

        local ts_captures = vim.treesitter.get_captures_at_cursor(win)

        local detail_lines = {
            "# Treesitter",
            "",
            my_utils.markdown.to_list(ts_captures, { value_format = "`%s`" })
        }

        my_utils.markdown_notify("Highlights under cursor", detail_lines)
    end
)
