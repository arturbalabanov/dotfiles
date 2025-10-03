-- ref: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

return {
    "rebelot/heirline.nvim",
    event = "UiEnter",
    dependencies = { "folke/tokyonight.nvim" },
    opts = function()
        local themes = require("plugins.heirline.themes")

        local theme_colors = themes[vim.g.colors_name]

        if theme_colors == nil then
            theme_colors = themes["default"]
        end

        if type(theme_colors) == "function" then
            theme_colors = theme_colors()
        end

        return {
            statusline = require("plugins.heirline.statusline"),
            tabline = require("plugins.heirline.tabline"),
            opts = {
                colors = vim.tbl_deep_extend("keep", theme_colors, themes["common"]),
            },
        }
    end,
    init = function()
        vim.o.showtabline = 2
        vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])

        -- vim.api.nvim_create_augroup("Heirline", { clear = true })
        -- vim.api.nvim_create_autocmd("ColorScheme", {
        --     callback = function()
        --         local themes = require("plugins.heirline.themes")
        --         local theme_colors = themes[vim.g.colors_name]
        --
        --         if theme_colors == nil then
        --             theme_colors = function()
        --                 return themes["default"]
        --             end
        --         elseif type(theme_colors) == "function" then
        --             theme_colors = function()
        --                 return vim.tbl_deep_extend("keep", theme_colors(), themes["common"])
        --             end
        --         else
        --             theme_colors = function()
        --                 return vim.tbl_deep_extend("keep", theme_colors, themes["common"])
        --             end
        --         end
        --
        --         require("heirline.utils").on_colorscheme(theme_colors)
        --     end,
        --     group = "Heirline",
        -- })
    end,
}
