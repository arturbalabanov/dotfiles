return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
        'tree-sitter/tree-sitter-html',
    },
    ft = { 'markdown', 'md', 'Avante', 'quarto' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        completions = { lsp = { enabled = true } },
        file_types = { 'markdown', 'md', 'Avante', 'quarto' },
        html = {
            enabled = true,
            render_modes = { 'n', 'c', 't' },
            comment = {
                conceal = false,
            },
        },
        code = {
            sign = false,
            language_icon = true,
            language_name = false,

            -- Determines how the top / bottom of code block are rendered.
            -- | none  | do not render a border                               |
            -- | thick | use the same highlight as the code body              |
            -- | thin  | when lines are empty overlay the above & below icons |
            -- | hide  | conceal lines unless language name or icon is added  |
            border = 'thin',

            -- Determines how code blocks & inline code are rendered.
            -- | none     | disables all rendering                                                    |
            -- | normal   | highlight group to code blocks & inline code, adds padding to code blocks |
            -- | language | language icon to sign column if enabled and icon + name above code blocks |
            -- | full     | normal + language                                                         |
            style = 'language',

            -- | right | right side of code block |
            -- | left  | left side of code block  |
            position = 'left',
        }
    }
}
