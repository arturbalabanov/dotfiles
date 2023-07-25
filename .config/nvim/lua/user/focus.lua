local my_utils = require("user.utils")

local focus = my_utils.opt_require("focus")
if focus == nil then
    return
end

local utils = require('focus.modules.utils')

local config = {
    enable = true,            -- Enable module
    commands = true,          -- Create Focus commands
    autoresize = {
        enable = true,        -- Enable or disable auto-resizing of splits
        width = 0,            -- Force width for the focused window
        height = 0,           -- Force height for the focused window
        minwidth = 0,         -- Force minimum width for the unfocused window
        minheight = 0,        -- Force minimum height for the unfocused window
        height_quickfix = 10, -- Set the height of quickfix panel
    },
    split = {
        bufnew = false, -- Create blank buffer for new split windows
        tmux = false,   -- Create tmux splits instead of neovim splits
    },
    ui = {
        number = false,                    -- Display line numbers in the focussed window only
        relativenumber = false,            -- Display relative line numbers in the focussed window only
        hybridnumber = true,               -- Display hybrid line numbers in the focussed window only
        absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

        cursorline = true,                 -- Display a cursorline in the focussed window only
        cursorcolumn = false,              -- Display cursorcolumn in the focussed window only
        colorcolumn = {
            enable = false,                -- Display colorcolumn in the foccused window only
            list = '+1',                   -- Set the comma-saperated list for the colorcolumn
        },
        signcolumn = true,                 -- Display signcolumn in the focussed window only
        winhighlight = false,              -- Auto highlighting for focussed/unfocussed windows
    }
}

focus.setup(config)

local ignore_filetypes = { "toggleterm", "neotest-output", "NvimTree", "TelescopePrompt" }
local ignore_buftypes = { 'nofile', 'prompt', 'popup', "help", "terminal" }

local augroup = vim.api.nvim_create_augroup('UserFocusRules', { clear = true })

vim.api.nvim_create_autocmd('WinEnter', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
            vim.b.focus_disable = true
            return
        end

        require("indent_blankline.commands").enable(false) -- false makes it buffer-only
        vim.b.indent_blankline_enabled = nil               -- setting to nil to not overwrite the indent_blankline filetype / buftype rules
    end,
})

vim.api.nvim_create_autocmd('WinLeave', {
    group = augroup,
    callback = function(_)
        require("indent_blankline.commands").disable(false) -- false makes it buffer-only
        vim.b.indent_blankline_enabled = nil                -- setting to nil to not overwrite the indent_blankline filetype / buftype rules
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.focus_disable = true
            return
        end
    end,
})

-- By default, the highlight groups are setup as such:
--   hi default link FocusedWindow VertSplit
--   hi default link UnfocusedWindow Normal
-- To change them, you can link them to a different highlight group, see `:h hi-default` for more info.
--
-- vim.cmd('hi link UnfocusedWindow CursorLine')
-- vim.cmd('hi link FocusedWindow VisualNOS')
