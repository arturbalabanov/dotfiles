local M = {}

M.to_list = function(tbl, opts)
    if not vim.tbl_islist(tbl) then
        error("argument tbl is not a list table")
    end

    local default_opts = {
        value_format = "%s",
    }
    opts = require("utils").apply_defaults(opts, default_opts)

    local lines = {}

    for _, value in pairs(tbl) do
        local formatted_value = string.format(opts.value_format, value)
        local list_item = string.format("* %s", formatted_value)
        table.insert(lines, list_item)
    end

    return table.concat(lines, "\n")
end

M.notify = function(title, msg_lines, level, opts)
    level = level or "info"
    opts = opts or {}

    local on_open = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end

    local message

    if type(msg_lines) == "string" then
        message = msg_lines
    elseif type(msg_lines) == "table" then
        message = table.concat(msg_lines, "\n")
    else
        message = vim.inspect(message)
    end

    opts.title = title
    opts.on_open = on_open

    vim.notify(message, level, opts)
end

return M
