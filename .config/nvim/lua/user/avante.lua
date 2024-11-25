local my_utils = require("user.utils")

local avante = my_utils.opt_require("avante")
if avante == nil then
    return
end

-- refs:
--    * https://github.com/yetone/avante.nvim
--    * https://github.com/yetone/avante.nvim/wiki/Recipe-and-Tricks#advanced-shortcuts-for-frequently-used-queries-756

avante.setup()

my_utils.nkeymap("<F1>", function() avante.toggle() end)
my_utils.ikeymap("<F1>", function() avante.toggle() end)
