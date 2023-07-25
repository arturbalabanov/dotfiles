local my_utils = require("user.utils")

local glow = my_utils.opt_require("glow")
if glow == nil then
    return
end

glow.setup({
    -- glow_path = "",                -- will be filled automatically with your glow bin in $PATH, if any
    -- install_path = "~/.local/bin", -- default path for installing glow binary
    -- border = "shadow",    -- floating window border config
    -- style = "dark|light", -- filled automatically with your current editor background, you can override using glow json style
    -- pager = false,
    width = 150,
    height = 200,
    -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
    width_ratio = 0.9,
    height_ratio = 0.9,
})
