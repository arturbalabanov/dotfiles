local my_utils = require("utils")

-- TODO: maybe one simple and effective way to do this is to:
--         * save the state into a new session
--         * close vim
--         * open that new session
--         * delete the new session
-- TODO: Use plenary.reload.reload_module  (maybe???)
-- TODO: Remove all mappings
-- TODO: Remove all autocommands and augroups
-- TODO: Improve based on NvChad's reload mechanism
-- ref: https://github.com/NvChad/NvChad/blob/v2.0/lua/core/init.lua#L74


-- lazy.nvim has a reload function, use with caution as it doesn't work for all plugins (ref: https://github.com/folke/lazy.nvim/issues/445)
-- I defined a wrapper for it in utils.plugin.reload. Create an autocmd to reload the relevant plugin(s) when
-- the config file is saved. Can be a bit tricky when multiple are defined but maybe lazy.nvim already stores the file where
-- they are defined in the plugin spec somewhere. but that way you can reload only one plugin at a time :)
-- For the time being this will do
vim.api.nvim_create_user_command(
    'ReloadPlugin',
    function(ctx)
        require("utils.plugin").reload(ctx.args)
        vim.notify("Reloaded plugin " .. ctx.args, vim.log.levels.INFO)
    end,
    { nargs = 1 }
)

--- Reload the entire configuration (disabled for now)
local function reload_nvim_config()
    -- stop all lsp clients
    for _, client in pairs(vim.lsp.get_clients()) do
        client.stop(true) -- force: true

        -- local client_fts = my_utils.get(client, "conf", "filetypes") or {}
        --
        -- if not vim.tbl_contains(client_fts, "lua") then
        --     client.stop(true) -- force: true
        -- end
    end

    local luacache = (_G.__luacache or {}).cache

    for name, _ in pairs(package.loaded) do
        if name:match('^user') or name == "treesitter" then
            package.loaded[name] = nil

            if luacache then
                luacache[name] = nil
            end
        end
    end

    -- Clear all autocommands as some of them are (intentionally) set with clear = false in the config
    -- so we want them to update on config reload too
    vim.cmd([[autocmd!]])

    -- vim.treesitter.start()
    dofile(vim.env.MYVIMRC)

    -- Reload after/ directory
    local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(glob, true, true)

    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end
end

local function simple_reload_nvim_file()
    vim.cmd.source("%")
end

local function reload_tmux_config()
    if vim.env.TMUX == nil then
        return
    end

    require("utils.shell").run_cmd("tmux source-file ~/.tmux.conf")
end

local function reload_kitty_config()
    require("utils.kitty").reload_config()
end

local reload_configs = {
    -- TODO: Re-enable
    -- {
    --     aliases = { "neovim", "nvim", "vim" },
    --     reload_func = reload_nvim_config,
    --     files_pattern = "*.lua",
    --     project_name = "nvim",
    -- },
    {
        aliases = { "neovim", "nvim", "vim" },
        reload_func = simple_reload_nvim_file,
        files_pattern = "lua/user/keymaps.lua",
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
