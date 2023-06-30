local my_utils = require("user.utils")

local focus = my_utils.opt_require("focus")
if focus == nil then
    return
end

local utils = require('focus.modules.utils')

local config = {
    -- The focussed window will no longer automatically resize.
    -- Other focus features are still available
    -- Default: true
    autoresize = true,

    -- Prevents focus automatically resizing windows based on configured excluded filetypes or buftypes
    -- Query filetypes using :lua print(vim.bo.ft) or buftypes using :lua print(vim.bo.buftype)
    -- Default[filetypes]: none
    -- Default[buftypes]: 'nofile', 'prompt', 'popup'
    excluded_filetypes = { "toggleterm" },
    excluded_buftypes = { 'nofile', 'prompt', 'popup', "help" },

    -- Force width for the focused window
    -- Default: Calculated based on golden ratio
    -- width = 120,

    -- Force minimum width for the unfocused window
    -- Default: Calculated based on golden ratio
    -- minwidth = 80,

    -- Force height for the focused window
    -- Default: Calculated based on golden ratio
    -- height = 40,

    -- Force minimum height for the unfocused window
    -- Default: 0
    -- minheight = 10,

    -- Sets the width of directory tree buffers such as NerdTree, NvimTree and CHADTree
    -- Default: vim.g.nvim_tree_width or 30
    -- treewidth = 20,

    -- Sets the height of quickfix panel
    -- Default: 10
    -- quickfixheight = 20,

    -- True: When a :Focus.. command creates a new split window, initialise it as a new blank buffer
    -- False: When a :Focus.. command creates a new split, retain a copy of the current window
    -- in the new window
    -- Default: false
    bufnew = false,

    -- Displays a cursorline in the focussed window only
    -- Not displayed in unfocussed windows
    -- Default: true
    cursorline = true,

    -- Displays a sign column in the focussed window only
    -- Gets the vim variable setcolumn when focus.setup() is run
    -- See :h signcolumn for more options e.g :set signcolum=yes
    -- Default: true, signcolumn=auto
    signcolumn = true,

    -- Displays a cursor column in the focussed window only
    -- See :h cursorcolumn for more options
    -- Default: false
    cursorcolumn = false,

    -- Displays a color column in the focussed window only
    -- See :h colorcolumn for more options
    -- Default: enable = false, width = 80
    -- colorcolumn = { enable = true },

    -- Displays line numbers in the focussed window only
    -- Not displayed in unfocussed windows
    -- Default: true
    -- number = true,

    -- Displays relative line numbers in the focussed window only
    -- Not displayed in unfocussed windows
    -- See :h relativenumber
    -- Default: false
    -- relativenumber = false,

    -- Displays hybrid line numbers in the focussed window only
    -- Not displayed in unfocussed windows
    -- Combination of :h relativenumber, but also displays the line number of the current line only
    -- Default: false
    hybridnumber = true,

    -- Preserve absolute numbers in the unfocussed windows
    -- Works in combination with relativenumber or hybridnumber
    -- Default: false
    absolutenumber_unfocussed = false,

    -- Enable auto highlighting for focussed/unfocussed windows
    -- Default: false
    -- winhighlight = true,
}

focus.setup(config)

-- By default, the highlight groups are setup as such:
--   hi default link FocusedWindow VertSplit
--   hi default link UnfocusedWindow Normal
-- To change them, you can link them to a different highlight group, see `:h hi-default` for more info.
-- vim.cmd('hi link UnfocusedWindow CursorLine')
-- vim.cmd('hi link FocusedWindow VisualNOS')

local custom_rules = {
    indent_blankline = {
        enter = require("indent_blankline.commands").enable,
        leave = require("indent_blankline.commands").disable,
    },
}

local function custom_rule_create_augroup(rule_name, toggle_type, func)
    local events

    if toggle_type == "enter" then
        events = { "BufEnter", "WinEnter" }
    elseif toggle_type == "leave" then
        events = { "BufLeave", "WinLeave" }
    else
        error("Invalid toggle type" .. toggle_type)
    end

    local augroup_name = "user_focus_" .. rule_name .. "_" .. toggle_type

    vim.api.nvim_create_autocmd(events, {
        group = vim.api.nvim_create_augroup(augroup_name, { clear = true }),
        callback = function(event)
            func()

            -- if not (utils.is_buffer_filetype_excluded(config)) then
            --     func()
            -- end
        end
    })
end

for rule_name, rules in pairs(custom_rules) do
    for toggle_type, func in pairs(rules) do
        custom_rule_create_augroup(rule_name, toggle_type, func)
    end
end
