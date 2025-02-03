local my_utils = require('user.utils')

local M = {}

M.ft_settings = {}

M.setting_type_to_dict = {
    win_opts = vim.wo,
    buf_opts = vim.bo,
    win_vars = vim.w,
    buf_vars = vim.b,
}

M.validate_settings = function(settings_to_apply)
    local available_setting_types = vim.tbl_keys(M.setting_type_to_dict)

    for filetype, settings_by_type in pairs(settings_to_apply) do
        if type(settings_by_type) ~= "table" then
            my_utils.error_fmt("expected table for filetype %s, got %s", filetype, type(settings_by_type))
        end

        for setting_type, _ in pairs(settings_by_type) do
            local setting_dict = M.setting_type_to_dict[setting_type]

            if setting_dict == nil then
                my_utils.error_fmt(
                    "unknown setting type '%s' for filetype %s, available types are: %s",
                    setting_type,
                    filetype,
                    vim.inspect(available_setting_types)
                )
            end
        end
    end
end


M.setup = function(ft_settings)
    M.validate_settings(ft_settings)

    M.ft_settings = ft_settings

    M.set_settings_in_augroups()
end

M.set_settings_in_augroups = function()
    for filetype, settings_by_type in pairs(M.ft_settings) do
        local function augroup_callback()
            for setting_type, settings in pairs(settings_by_type) do
                for key, setting_value in pairs(settings) do
                    local actual_value

                    if type(setting_value) == "function" then
                        actual_value = setting_value()
                    else
                        actual_value = setting_value
                    end

                    M.setting_type_to_dict[setting_type][key] = actual_value
                end
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup('UserFileTypeSpecificOptions', { clear = false }),
            pattern = filetype,
            callback = augroup_callback,
        })
    end
end

return M
