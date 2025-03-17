local my_utils = require("user.utils")

return {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = false,

        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        detection_methods = { "pattern" },

        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        -- patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "init.lua", "pyproject.toml", "Makefile", "package.json" },
        patterns = { ".project_root", ".git", "_darcs", ".hg", ".bzr", ".svn" },

        -- Table of lsp clients to ignore by name
        -- eg: { "efm", ... }
        ignore_lsp = {},

        -- Don't calculate root dir on specific directories
        -- Ex: { "~/.cargo/*", ... }
        exclude_dirs = { "~/.local/share" },

        -- Show hidden files in telescope
        show_hidden = true,

        -- When set to false, you will get a message when project.nvim changes your
        -- directory.
        silent_chdir = true,

        -- What scope to change the directory, valid options are
        -- * global (default)
        -- * tab
        -- * win
        scope_chdir = 'win',

        -- Path where project.nvim will store the project history for use in
        -- telescope
        datapath = vim.fn.stdpath("data"),
    },
    dependencies = "nvim-telescope/telescope.nvim",
    config = function(_, opts)
        require("project_nvim").setup(opts)

        my_utils.on_plugin_load("telescope.nvim", function()
            require("telescope").load_extension("projects")
        end)
    end
}
