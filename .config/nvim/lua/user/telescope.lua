local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local telescope_builtin = require('telescope.builtin')
local utils = require("user.utils")
local lga_actions = require("telescope-live-grep-args.actions")
local lga_shortcuts = require("telescope-live-grep-args.shortcuts")
local sorters = require("telescope.sorters")

local telescope_extensions_to_load = {
    "yadm_files",
    "git_or_yadm_files",
    "live_grep_args",
    "advanced_git_search",
    "zoxide",
    "frecency",
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
        },
        layout_config = {
            horizontal = {
                width = 0.9,
                prompt_position = "top",
            },
            vertical = {
                prompt_position = "top",
                mirror = true,
                width = 0.9,
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
        frecency = {
            ignore_patterns = { "*/node_modules/*", '*/.git/*' },
            default_workspace = 'CWD',
            workspaces = {
                ["conf"] = vim.fn.expand("$HOME/.config"),
                ["dev"]  = vim.fn.expand("$HOME/dev"),
            },
            show_unindexed = true,
            show_scores = true,
            show_filter_column = false,
        },
        zoxide = {
            mappings = {
                default = {
                    action = function(selection)
                        vim.cmd.lchdir(selection.path)
                        telescope.extensions.frecency.frecency({ workspace = 'CWD' })
                    end,
                },
                ["<C-f>"] = {
                    action = function(selection)
                        telescope.extensions.live_grep_args.live_grep_args({
                            search_dirs = { selection.path },
                            cwd = selection.path,
                        })
                    end,
                },
            },
        }
    }
}

for _, extension_name in pairs(telescope_extensions_to_load) do
    telescope.load_extension(extension_name)
end

utils.nkeymap("<leader>t", telescope_builtin.builtin)
utils.nkeymap("<leader>h", telescope_builtin.help_tags)
utils.nkeymap('<leader>q', telescope_builtin.quickfix)

-- utils.nkeymap("<leader>p", telescope_builtin.find_files)
-- utils.nkeymap("<leader>f", telescope_builtin.live_grep)
-- utils.nkeymap("<leader>*", telescope_builtin.grep_string)

utils.nkeymap("<leader>p", telescope.extensions.frecency.frecency)
utils.nkeymap("<leader><leader>", telescope.extensions.zoxide.list)
utils.nkeymap("<leader>f", telescope.extensions.live_grep_args.live_grep_args)
utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
utils.vkeymap("<leader>*", lga_shortcuts.grep_visual_selection)

utils.nkeymap("<leader>c", telescope.extensions.yadm_files.yadm_files)
