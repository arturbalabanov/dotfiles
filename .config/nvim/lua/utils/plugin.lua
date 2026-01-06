-- NOTE: This module is adapted from LazyVim
-- ref: https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/util/init.lua

local M = {}

-- TODO: Maybe convert this into a class and make the rest methods?

-- based on lazyvim/util/init.lua:lazy_notify
function M.delay_notifications_until_patched(opts)
    opts = opts or { timeout_ms = 500 }

    local notifs = {}
    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.uv.new_timer()
    local check = assert(vim.uv.new_check())

    local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)
    -- or if it took more than the timeout (in ms), then something went wrong
    timer:start(opts.timeout_ms, 0, replay)
end

M.is_loaded = function(plugin_name)
    -- TODO: this doesn't return a boolean value!
    -- TODO: If the plugin name is misspelled (e.g. heirline instead of heirline.nvim), this returns nil instead of an
    -- error
    local Config = require("lazy.core.config")
    return Config.plugins[plugin_name] and Config.plugins[plugin_name]._.loaded
end

M.get_opts = function(plugin_name)
    local plugin = require("lazy.core.config").spec.plugins[plugin_name]
    if not plugin then
        error("Plugin '" .. plugin_name .. "' not found", vim.log.levels.ERROR)
        return {}
    end

    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
end

M.on_load = function(plugin_name, callback_func)
    if M.is_loaded(plugin_name) then
        callback_func(plugin_name)
        return
    else
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            callback = function(event)
                if event.data == plugin_name then
                    callback_func(plugin_name)
                    return true
                end
            end,
        })
    end
end

M.reload = function(plugin_name)
    -- ref: https://github.com/MaximilianLloyd/lazy-reload.nvim/blob/main/lua/lazy-reload/init.lua

    local plugins = require("lazy.core.config").plugins
    local plugin = plugins[plugin_name]

    if plugin == nil then
        error("Cannot reload plugin '" .. plugin_name .. "': plugin not found", vim.log.levels.ERROR)
        return
    end

    if not plugin._.loaded then
        error("Cannot reload plugin '" .. plugin_name .. "': plugin is not loaded", vim.log.levels.ERROR)
        return
    end

    require("lazy.core.loader").reload(plugin)
end

return M
