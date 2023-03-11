local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local builtin = require('telescope.builtin')
local utils = require("user.utils")

telescope.setup {
    defaults = {
        -- path_display = { "smart" },
        sorting_strategy = "ascending",
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        border = true,
        borderchars = {
            prompt = { "─", "│", " ", "│", "╭", "┬", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "┴", "╰" },
            preview = { "─", "│", "─", " ", "─", "╮", "╯", "─" },
        },
        layout_config = {
            horizontal = {
                width = 0.9,
                prompt_position = "top"
            }
        },
        mappings = {
            i = {
                ["<esc>"] = actions.close
            },
            n = {
                ["t"] = actions.select_tab
            }
        }
    },
    pickers = {
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
    }

}

utils.nkeymap("<leader><leader>", vim.cmd.Telescope)
utils.nkeymap("<leader>p", builtin.find_files)
utils.nkeymap("<leader>h", builtin.help_tags)
utils.nkeymap("<leader>f", builtin.live_grep)
utils.nkeymap("<leader>*", builtin.grep_string)

telescope.load_extension("yadm_files")
telescope.load_extension("git_or_yadm_files")

utils.nkeymap("<leader>c", function() vim.cmd.Telescope("yadm_files") end)
