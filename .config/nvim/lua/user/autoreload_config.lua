local my_utils = require("utils")

-- TODO: add a command to toggle the automatic reload (similar to how I have ToggleFormatting), very useful when making
--       very minor changes code I don't need to reload for
-- TODO: Also, add an indicator in heirline about the status of this (enabled or disabled autoreload with an option to click
--       on it and run it manually)
-- TODO: Maybe it's worth adding a similar indicator for the autoformat too (maybe before that too as the functionality is
--       already there and then i can quickly add this feature to the autoreload :))

local function reload_nvim_config()
    -- TODO: Add option to restart all other servers

    -- returned as nvim.123.0
    local server_name = vim.fs.basename(vim.v.servername)

    local server_pid = server_name:match("nvim%.(%d+)%.%d+")
    if server_pid == nil then
        my_utils.simple_notify("not reloading neovim config: failed to extract PID from server name")
        return
    end

    local fallback_session_path = vim.fn.stdpath("state") .. "/restart_session_" .. server_pid .. ".vim"
    local session_path = vim.v.this_session ~= "" and vim.v.this_session or fallback_session_path
    session_path = vim.fn.fnameescape(session_path)

    local show_notification_cmd = [[ require('utils').simple_notify("neovim configuration reloaded!") ]]

    -- NOTE: Bang to overwrite existing session file if it exists
    local restart_cmd = ("mksession! %s | restart source %s | lua %s "):format(
        session_path,
        session_path,
        show_notification_cmd
    )
    vim.cmd(restart_cmd)
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

vim.api.nvim_create_user_command("ReloadConfig", reload_config, { nargs = "?" })

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

local autoreload_augroup = vim.api.nvim_create_augroup("UserAutoReloadConfigs", { clear = true })

for _, config in ipairs(reload_configs) do
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = autoreload_augroup,
        pattern = config.files_pattern,
        callback = create_autocmd_callback(config),
    })
end
