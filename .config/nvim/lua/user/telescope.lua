local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local builtin = require('telescope.builtin')
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
        },
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
        }
    }

}

telescope.load_extension("yadm_files")
telescope.load_extension("git_or_yadm_files")
telescope.load_extension("live_grep_args")

utils.nkeymap("<leader><leader>", vim.cmd.Telescope)
utils.nkeymap("<leader>p", builtin.find_files)
utils.nkeymap("<leader>h", builtin.help_tags)

-- utils.nkeymap("<leader>f", builtin.live_grep)
-- utils.nkeymap("<leader>*", builtin.grep_string)

utils.nkeymap("<leader>f", telescope.extensions.live_grep_args.live_grep_args)
utils.nkeymap("<leader>*", lga_shortcuts.grep_word_under_cursor)
utils.vkeymap("<leader>*", lga_shortcuts.grep_visual_selection)

utils.nkeymap("<leader>c", function() vim.cmd.Telescope("yadm_files") end)
