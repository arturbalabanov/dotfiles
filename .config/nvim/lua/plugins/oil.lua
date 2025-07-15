return {
    'stevearc/oil.nvim',
    lazy = false, -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    dependencies = { "nvim-tree/nvim-web-devicons" },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        keymaps = {
            -- disable <C-h> and <C-l> as I use these to navigate between tabpages
            ['<C-h>'] = false,
            ['<C-l>'] = false,
        },
    },
}
