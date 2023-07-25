local my_utils = require("user.utils")

local tint = my_utils.opt_require("tint")
if tint == nil then
    return
end

tint.setup({
    tint = -60,                                                 -- Darken colors, use a positive value to brighten
    saturation = 0.3,                                           -- Saturation to preserve
    transforms = require("tint").transforms.SATURATE_TINT,      -- Showing default behavior, but value here can be predefined set of transforms
    tint_background_colors = false,                             -- Tint background portions of highlight groups
    highlight_ignore_patterns = { "WinSeparator", "Status.*" }, -- Highlight group patterns to ignore, see `string.find`
    window_ignore_function = function(target_winid)
        local target_win_config = vim.api.nvim_win_get_config(target_winid)
        local floating = target_win_config.relative ~= ""

        local bufid = vim.api.nvim_win_get_buf(target_winid)
        local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
        local filetype = vim.api.nvim_buf_get_option(bufid, "filetype")

        local tabpage = vim.api.nvim_win_get_tabpage(target_winid)
        local tabpage_wins = vim.api.nvim_tabpage_list_wins(tabpage)

        if floating then
            return true
        end

        if buftype == "terminal" then
            return true
        end

        -- if filetype == "NvimTree" then
        --     return true
        -- end

        -- Don't tint any windows which are the parents of floating windows
        -- (e.g. main windows when goto_preview is called)
        for _, winid in pairs(tabpage_wins) do
            local win_config = vim.api.nvim_win_get_config(winid)

            if win_config.relative == "win" and win_config.win == target_winid then
                return true
            end
        end
    end
})
