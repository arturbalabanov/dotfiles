local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local telescope_builtin = require('telescope.builtin')
local lga_actions = require("telescope-live-grep-args.actions")
local lga_shortcuts = require("telescope-live-grep-args.shortcuts")

local my_utils = require("user.utils")

local telescope_extensions_to_load = {
    "yadm_files",
    "git_or_yadm_files",
    "live_grep_args",
    "advanced_git_search",
    "frecency",
    "projects",
    "glyph",
}


telescope.setup {
    defaults = {
        -- path_display = { "smart" },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        border = true,
        wrap_results = false,
        file_ignore_patterns = {
            "^.git/",
            "^plugin/packer_compiled.lua$",
        },
        layout_config = {
            prompt_position = "top",
            width = 0.9,
            vertical = {
                mirror = true,
            },
            scroll_speed = 1,
        },
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-t>"] = actions.select_tab,
                ["<C-q>"] = actions.send_to_qflist,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-p>"] = actions.preview_scrolling_up,
            },
            n = {
                ["t"] = actions.select_tab,
                ["q"] = actions.send_to_qflist,
                ["p"] = actions_layout.toggle_preview,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-p>"] = actions.preview_scrolling_up,
            },
        }
    },
    pickers = {
        find_files = {
            hidden = true,
        },
        live_grep = {
            layout_strategy = 'vertical',
            disable_coordinates = true,
            additional_args = { '--trim' },
        },
        grep_string = {
            layout_strategy = 'vertical',
            disable_coordinates = true,
            additional_args = { '--trim' },
        },
        colorscheme = {
            theme = "dropdown",
            enable_preview = true,
            previewer = false,
        },
        builtin = {
            -- theme = "dropdown",
            include_extensions = true,
            previewer = false,
            border = true,
            borderchars = {
                prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            },
            layout_strategy = 'vertical',
            layout_config = {
                vertical = {
                    width = 0.3,
                    prompt_position = "top"
                },
            },
        }
    },
    extensions = {
        live_grep_args = {
            layout_strategy = 'vertical',
            auto_quoting = true,
            mappings = {
                -- extend mappings
                n = {
                    ["f"] = lga_actions.quote_prompt({ postfix = " -t" }),
                },
            },
            disable_coordinates = true,
            additional_args = { '--trim' },
        },
        advanced_git_search = {
            -- Fugitive or diffview
            diff_plugin = "diffview",
            -- Customize git in previewer
            -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
            git_flags = {},
            -- Customize git diff in previewer
            -- e.g. flags such as { "--raw" }
            git_diff_flags = {},
            -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
            show_builtin_git_pickers = false,
        },
        -- ref: https://github.com/nvim-telescope/telescope-frecency.nvim
        frecency = {
            ignore_patterns = { "*/node_modules/*", '*/.git/*' },
            default_workspace = 'CWD',
            workspaces = {
                ["conf"] = vim.fn.expand("$HOME/.config"),
                ["dev"]  = vim.fn.expand("$HOME/dev"),
            },
            show_unindexed = true,
            show_scores = true,
            show_filter_column = true,
        },
    }
}

for _, extension_name in pairs(telescope_extensions_to_load) do
    telescope.load_extension(extension_name)
end

my_utils.nkeymap("<leader>t", telescope_builtin.builtin)
my_utils.nkeymap("<leader>h", telescope_builtin.help_tags)
my_utils.nkeymap('<leader>q', telescope_builtin.quickfix)

-- utils.nkeymap("<leader>p", telescope_builtin.find_files)
-- utils.nkeymap("<leader>f", telescope_builtin.live_grep)
-- utils.nkeymap("<leader>*", telescope_builtin.grep_string)

my_utils.nkeymap("<leader>p", function()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
    local winnr = vim.api.nvim_tabpage_get_win(tabpage)

    if vim.fn.getcwd(winnr, tabnr) == vim.fn.expand("$HOME") then
        telescope.extensions.frecency.frecency({ workspace = "conf" })
    else
        telescope.extensions.frecency.frecency()
    end
end)

my_utils.nkeymap("<leader><leader>", telescope.extensions.projects.projects)
my_utils.nkeymap("<leader>f", telescope.extensions.live_grep_args.live_grep_args)
my_utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
my_utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
my_utils.vkeymap("<leader>*", lga_shortcuts.grep_visual_selection)

my_utils.nkeymap("<leader>c", telescope.extensions.yadm_files.yadm_files)
