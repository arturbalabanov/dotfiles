local my_utils = require("user.utils")

-- TODO: Use plenary.reload.reload_module
-- TODO: Remove all mappings
-- TODO: Remove all autocommands and augroups
-- TODO: Improve based on NvChad's reload mechanism
-- ref: https://github.com/NvChad/NvChad/blob/v2.0/lua/core/init.lua#L74

--- Reload the entire configuration
local function reload_nvim_config()
    require("null-ls.config").reset()

    -- stop all lsp clients
    for _, client in pairs(vim.lsp.get_active_clients()) do
        client.stop(true) -- force: true

        -- local client_fts = my_utils.get(client, "conf", "filetypes") or {}
        --
        -- if not vim.tbl_contains(client_fts, "lua") then
        --     client.stop(true) -- force: true
        -- end
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
end

local function reload_tmux_config()
    my_utils.run_shell_cmd("tmux source-file ~/.tmux.conf")
end

local function reload_kitty_config()
    my_utils.run_shell_cmd("kill -SIGUSR1 $(pgrep -a kitty)")
end

local reload_configs = {
    {
        aliases = { "neovim", "nvim", "vim" },
        reload_func = reload_nvim_config,
        files_pattern = "*.lua",
        project_name = "nvim",
    },
    {
        aliases = { "tmux" },
        reload_func = reload_tmux_config,
        files_pattern = ".tmux.conf",
    },
    {
        aliases = { "kitty" },
        reload_func = reload_kitty_config,
        files_pattern = "kitty.conf",
    },
}

local function reload_config(opts)
    local config_type = opts.args or ""

    for _, config in ipairs(reload_configs) do
        local config_name = config.aliases[1]

        if config_type == "" or vim.tbl_contains(config.aliases, config_type) then
            config.reload_func()

            my_utils.simple_notify(config_name .. " configuration reloaded!")
        end
    end
end

vim.api.nvim_create_user_command('ReloadConfig', reload_config, { nargs = '?' })

local function create_autocmd_callback(autoreload_config)
    return function(event)
        local config_name = autoreload_config.aliases[1]
        local autoreload_on_project = autoreload_config.project_name

        local error_msg_prefix = "not reloading " .. config_name .. " config: "

        if autoreload_on_project ~= nil then
            local status_ok, project = pcall(require, "project_nvim.project")
            if not status_ok then
                my_utils.simple_notify(error_msg_prefix .. "project_nvim.project failed to load")
                return
            end

            local status_ok, project_root = pcall(project.get_project_root)
            if not status_ok then
                my_utils.simple_notify(error_msg_prefix .. "project root not found")
                return
            end

            local project_name = vim.fn.fnamemodify(project_root, ":t")

            if project_name ~= autoreload_on_project then
                my_utils.simple_notify(error_msg_prefix .. "project is not " .. autoreload_on_project)
                return
            end
        end

        autoreload_config.reload_func()
        my_utils.simple_notify(config_name .. " configuration reloaded!")
    end
end

local autoreload_augroup = vim.api.nvim_create_augroup('UserAutoReloadConfigs', { clear = true })

for _, config in ipairs(reload_configs) do
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = autoreload_augroup,
        pattern = config.files_pattern,
        callback = create_autocmd_callback(config)
    })
end
