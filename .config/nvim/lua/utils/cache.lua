-- TODO: probably there is a similar module in plenary (or maybe use buflocal variables)
--       also look at what pytrize is doing to implement its own cache

-- TODO: Also look into snacks.nvim for caching

local M = {}

local NO_VALUE = '__NO_VALUE_SENTINEL__'

local cache_vault = {}

M.get_or_update = function(namespace, key, get_value_func, opts)
    opts = require("utils").apply_defaults(opts, { save_nil_values = true })

    local vault = cache_vault[namespace]

    if vault == nil then
        vault = {}
        cache_vault[namespace] = vault
    end

    local cached_value = vault[key]

    if cached_value == NO_VALUE then
        -- get_value_func returned nil last time it was called
        return nil
    end

    if cached_value ~= nil then
        return cached_value
    end

    local new_value = get_value_func(key)

    if new_value == nil and opts.save_nil_values then
        vault[key] = NO_VALUE
    else
        vault[key] = new_value
    end

    return new_value
end


return M
