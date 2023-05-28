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


telescope.setup {
    defaults = {
        -- path_display = { "smart" },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        border = true,
        wrap_results = true,
        file_ignore_patterns = {
            "^.git/",
        },
        borderchars = {
            prompt = { "─", "│", " ", "│", "╭", "┬", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "┴", "╰" },
            preview = { "─", "│", "─", " ", "─", "╮", "╯", "─" },
        },
        layout_config = {
            horizontal = {
                width = 0.9,
                prompt_position = "top"
            },
        },
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
            n = {
                ["t"] = actions.select_tab,
                ["p"] = actions_layout.toggle_preview,
            },
        }
    },
    pickers = {
        find_files = {
            hidden = true,
        },
        live_grep = {
            disable_coordinates = true,
            additional_args = { '--trim' }
        },
        grep_string = {
            disable_coordinates = true,
            additional_args = { '--trim' }
        },
        colorscheme = {
            theme = "dropdown",
            enable_preview = true,
            previewer = false
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
            auto_quoting = true,
            mappings = { -- extend mappings
                n = {
                    ["f"] = lga_actions.quote_prompt({ postfix = " -t" }),
                },
            },
            disable_coordinates = true,
            additional_args = { '--trim' }
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
        }
    }

}

telescope.load_extension("yadm_files")
telescope.load_extension("git_or_yadm_files")
telescope.load_extension("live_grep_args")
telescope.load_extension("advanced_git_search")

utils.nkeymap("<leader><leader>", telescope_builtin.builtin)
utils.vkeymap("<leader><leader>", telescope_builtin.builtin)
utils.nkeymap("<leader>p", telescope_builtin.find_files)
utils.nkeymap("<leader>h", telescope_builtin.help_tags)

-- utils.nkeymap("<leader>f", telescope_builtin.live_grep)
-- utils.nkeymap("<leader>*", telescope_builtin.grep_string)

utils.nkeymap("<leader>f", telescope.extensions.live_grep_args.live_grep_args)
utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
utils.vkeymap("<leader>*", lga_shortcuts.grep_visual_selection)

utils.nkeymap("<leader>c", telescope.extensions.yadm_files.yadm_files)
