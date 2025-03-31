local M = {}

M.send_cmd = function(cmd, ...)
    local args = { ... }
    local kitty_listen_socket = vim.fn.expand("$KITTY_LISTEN_ON")
    local kitty_cmd = string.format("kitty @ --to %s %s -- %s", kitty_listen_socket, cmd, table.concat(args, " "))

    require("utils.shell").run_cmd(kitty_cmd)
end

M.reload_config = function()
    require("utils.shell").run_cmd("kill -SIGUSR1 $(pgrep -a kitty)")
end

return M
