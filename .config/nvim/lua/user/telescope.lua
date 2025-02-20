local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local telescope_builtin = require('telescope.builtin')
local trouble = require("trouble.sources.telescope")
local nvim_search = require('search')

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
            include_extensions = true,
            previewer = false,
            border = true,
            layout_strategy = 'vertical',
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

nvim_search.setup({
    mappings = { -- NOTE: will be set in normal and insert mode(!)
        next = "<Tab>",
        prev = "<S-Tab>"
    },
    append_tabs = { -- These will always be added to every tab group
        {
            name = "Others",
            tele_func = telescope_builtin.builtin,
        },
    },
    tabs = {
        {
            name = "Files",
            tele_func = function(opts)
                opts = opts or {}

                local tabpage = vim.api.nvim_get_current_tabpage()
                local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
                local winnr = vim.api.nvim_tabpage_get_win(tabpage)

                if vim.fn.getcwd(winnr, tabnr) == vim.fn.expand("$HOME") then
                    opts.cwd = '~/.config/nvim'
                end

                telescope_builtin.find_files(opts)
            end
        },
        {
            name = "Live Grep",
            tele_func = telescope_builtin.live_grep,
        },
        {
            name = "Commits",
            tele_func = telescope_builtin.git_commits,
            available = function()
                -- TODO: make this work with yadm_files too
                return vim.fn.isdirectory(".git") == 1
            end,
        },
        {
            name = "Glyphs",
            tele_func = telescope.extensions.glyph.glyph,
        },
        {
            name = "Projects",
            tele_func = telescope.extensions.projects.projects,
        },
        {
            name = "Help",
            tele_func = telescope_builtin.help_tags,
        },
    },
})

local pytest_fixtures_ts_query = [[
(decorated_definition
   (decorator
     [
      (call
       function: (
         attribute
            object: (identifier) @_obj_name
            attribute: (identifier) @_dec_name))
     (attribute
        object: (identifier) @_obj_name
        attribute: (identifier) @_dec_name)
    (#eq? @_obj_name "pytest")
    (#eq? @_dec_name "fixture")
     ]
     )
 definition: (
   function_definition) @capture)
]]

local pytest_fixtures_ast_grep_query = [[
rule:
  pattern: def $FIXTURE_NAME
  kind: function_definition
  follows:
    kind: decorator
    has:
      kind: identifier
      regex: ^fixture$
      stopBy: end
]]

my_utils.nkeymap("<leader>p", nvim_search.open)
my_utils.nkeymap("<leader>f", function() nvim_search.open({ tab_name = "Live Grep" }) end)
my_utils.nkeymap("<leader>h", function() nvim_search.open({ tab_name = "Help" }) end)
my_utils.nkeymap("<leader>*", telescope_builtin.grep_string)

my_utils.nkeymap("<leader>c", telescope.extensions.yadm_files.yadm_files)
