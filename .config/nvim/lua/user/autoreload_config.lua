local my_utils = require("user.utils")


--- Reload the entire configuration
local reload_config = function()
    require("null-ls.config").reset()

    -- stop all non-lua lsp clients
    for _, client in pairs(vim.lsp.get_active_clients()) do
        local client_fts = my_utils.get(client, "conf", "filetypes") or {}

        if not vim.tbl_contains(client_fts, "lua") then
            client.stop(true) -- force: true
        end
    end

    for name, _ in pairs(package.loaded) do
        if name:match('^user') then
            package.loaded[name] = nil
        end
    end

    -- Clear all autocommands as some of them are (intentionally) set with clear = false in the config
    -- so we want them to update on config reload too
    vim.cmd([[autocmd!]])

    dofile(vim.env.MYVIMRC)

    -- Reload after/ directory
    local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(glob, true, true)

    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end

    my_utils.simple_notify("Nvim configuration reloaded!")
end

vim.api.nvim_create_user_command('ReloadConfig', reload_config, { nargs = 0 })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup('UserAutoReloadConfig', { clear = true }),
    pattern = "*.lua",
    callback = function()
        local status_ok, project = pcall(require, "project_nvim.project")
        if not status_ok then
            my_utils.simple_notify("not reloading nvim config: project_nvim.project failed to load")
            return
        end

        local status_ok, project_root = pcall(project.get_project_root)
        if not status_ok then
            my_utils.simple_notify("not reloading nvim config: project root not found")
            return
        end

        local project_name = vim.fn.fnamemodify(project_root, ":t")

        if project_name ~= 'nvim' then
            my_utils.simple_notify("not reloading nvim config: project is not nvim")
            return
        end

        reload_config()
    end
})
