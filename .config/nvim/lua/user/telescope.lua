local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local telescope_builtin = require('telescope.builtin')
local trouble = require("trouble.sources.telescope")

local my_utils = require("user.utils")

local telescope_extensions_to_load = {
    "yadm_files",
    "git_or_yadm_files",
    "advanced_git_search",
    "projects",
    "glyph",
}

for _, extension_name in pairs(telescope_extensions_to_load) do
    telescope.load_extension(extension_name)
end

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
                ["<C-q>"] = actions.smart_send_to_qflist,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-p>"] = actions.preview_scrolling_up,
            },
            n = {
                ["t"] = actions.select_tab,
                ["q"] = actions.smart_send_to_qflist,
                ["p"] = actions_layout.toggle_preview,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<C-p>"] = actions.preview_scrolling_up,
                ["s"] = actions.file_split,
                ["v"] = actions.file_vsplit,
                ["<C-t>"] = trouble.open,
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
    }
}

my_utils.nkeymap("<leader>t", telescope_builtin.builtin)
my_utils.nkeymap("<leader>h", telescope_builtin.help_tags)

my_utils.nkeymap("<leader>f", telescope_builtin.live_grep)
my_utils.nkeymap("<leader>*", telescope_builtin.grep_string)

my_utils.nkeymap("<leader>p", function()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
    local winnr = vim.api.nvim_tabpage_get_win(tabpage)

    local args = {}
    if vim.fn.getcwd(winnr, tabnr) == vim.fn.expand("$HOME") then
        args.cwd = '~/.config/nvim'
    end

    telescope_builtin.find_files(args)
end)

my_utils.nkeymap("<leader><leader>", telescope.extensions.projects.projects)
my_utils.nkeymap("<leader>g", telescope.extensions.glyph.glyph)
my_utils.nkeymap("<leader>c", telescope.extensions.yadm_files.yadm_files)
