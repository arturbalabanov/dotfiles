local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
    return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup {
    ensure_installed = { "lua", "python" }, -- put the language you want in this array
    -- ensure_installed = "all", -- one of "all" or a list of languages
    sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
    highlight = {
        enable = true,
    },
    autopairs = {
        enable = true,
    },
    indent = { enable = true },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
