local status_ok, project_nvim = pcall(require, "project_nvim")
if not status_ok then
    return
end

local get_project_root = require("project_nvim.project").get_project_root

project_nvim.setup({
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
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup('UserSetProjectPathVariable', { clear = true }),
    callback = function(event)
        local var_name = "project_root"
        local bufnr = event.buf

        if not vim.api.nvim_buf_get_name(bufnr) then
            return
        end

        local new_val = get_project_root()
        local found, curr_val = pcall(vim.api.nvim_buf_get_var, bufnr, var_name)

        -- Both checks for nil and also setting value is more expensive than
        -- reading it, so only set it when the project has changed

        if not found or curr_val ~= new_val then
            vim.api.nvim_buf_set_var(bufnr, var_name, new_val)
        end
    end
})
