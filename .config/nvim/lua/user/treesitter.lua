local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
    return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup {
    ensure_installed = "all",
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

-- ref: https://github.com/nvim-treesitter/nvim-treesitter/tree/master/queries

vim.treesitter.set_query("lua", "folds", [[
    (function_definition) @fold
]])

-- TODO: Add decorators
vim.treesitter.set_query("python", "folds", [[
    (function_definition) @fold
    (class_definition) @fold
]])

vim.treesitter.set_query("go", "folds", [[
    (function_declaration) @fold
    (method_declaration) @fold
    (type_declaration) @fold
]])

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
