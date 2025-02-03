local status_ok, lspimport = pcall(require, "lspimport")
if not status_ok then
    return
end
local my_utils = require("user.utils")


my_utils.nkeymap('<leader>i', require("lspimport").import)
