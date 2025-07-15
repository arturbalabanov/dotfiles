local telescope_extensions_to_load = {
    "yadm_files",
    "git_or_yadm_files",
    "advanced_git_search",
    "glyph",
    "emoji",
}

return {
    {
        'nvim-telescope/telescope.nvim',
        version = '0.1.8',
        opts = function()
            local actions = require("telescope.actions")
            local actions_layout = require("telescope.actions.layout")
            local trouble = require("trouble.sources.telescope")

            return {
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
                        "^.mypy_cache/",
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
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
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
                        find_command = { "rg", "--files", "--sortr=modified" },
                    },
                    live_grep = {
                        layout_strategy = 'vertical',
                        disable_coordinates = true,
                        additional_args = { '--trim', "--sortr=modified" },
                    },
                    grep_string = {
                        layout_strategy = 'vertical',
                        disable_coordinates = true,
                        additional_args = { '--trim', "--sortr=modified" },
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
                    },
                    lsp_document_symbols = {
                        layout_strategy = 'vertical',
                        symbol_width = 80,
                    },
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
        end,
        config = function(_, opts)
            local telescope = require("telescope")
            for _, extension_name in pairs(telescope_extensions_to_load) do
                telescope.load_extension(extension_name)
            end

            telescope.setup(opts)
        end,
        keys = {
            { "<leader>*",        function() require("telescope.builtin").grep_string() end,              desc = "Telescope: Grep word under cursor" },
            { "<leader>c",        function() require("telescope").extensions.yadm_files.yadm_files() end, desc = "Telescope: YADM files" },
            { "<leader>C",        function() require("telescope.builtin").commands() end,                 desc = "Telescope: Commands" },
            { "<leader><leader>", function() require("telescope.builtin").builtin() end,                  desc = "Telescope: Pickers" },
            {
                "<leader>l",
                function()
                    local ft = vim.bo.filetype

                    local symbol_types_per_ft = {
                        python = { "class", "function", "method" },
                        lua = { "function" },
                        toml = { "object" },
                    }

                    local symbol_types = symbol_types_per_ft[ft]

                    if symbol_types == nil then
                        require("telescope.builtin").lsp_document_symbols()
                    else
                        require("telescope.builtin").lsp_document_symbols({ symbols = symbol_types })
                    end
                end,
                desc = "Telescope: LSP Document Symbols",
            },
        },
    },
    {
        "ghassan0/telescope-glyph.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    {
        "xiyaowong/telescope-emoji.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    {
        "pschmitt/telescope-yadm.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    {
        "aaronhallaert/advanced-git-search.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-fugitive", -- to show diff splits and open commits in browser
            "tpope/vim-rhubarb",  -- to open commits in browser with fugitive
            -- optional: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            "sindrets/diffview.nvim",
        },
    },
    {
        "FabianWirth/search.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        opts = function()
            local telescope = require("telescope")
            local telescope_builtin = require('telescope.builtin')

            return {
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
                        name = "Help",
                        tele_func = telescope_builtin.help_tags,
                    },
                },
            }
        end,
        keys = {
            { "<leader>p", function() require('search').open() end,                           desc = "Search: Open files" },
            { "<leader>f", function() require('search').open({ tab_name = "Live Grep" }) end, desc = "Search: Live Grep" },
            { "<leader>h", function() require('search').open({ tab_name = "Help" }) end,      desc = "Search: Help" },
        },
    },
}
