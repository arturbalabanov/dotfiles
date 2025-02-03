local M = {}

local ignore_list = {
    { selected_filetype = "toggleterm" },
    { selected_filetype = "neotest-output" },
    { selected_filetype = "neotest-summary" },
    { selected_filetype = "NvimTree" },
    { selected_filetype = "TelescopePrompt" },
    { selected_filetype = "DressingInput" },
    { selected_filetype = "OverseerList" },
    { selected_filetype = "Avante" },
    { selected_filetype = "AvanteInput" },
    { selected_filetype = "dapui_breakpoints" },
    { selected_filetype = "dapui_scopes" },
    { selected_filetype = "dapui_breakpoints" },
    { selected_filetype = "dapui_stacks" },
    { selected_filetype = "dapui_watches" },
    { selected_filetype = "dap-repl" },
    { selected_filetype = "dapui_console" },
    { selected_buftype = 'nofile' },
    { selected_buftype = 'prompt' },
    { selected_buftype = 'popup' },
    { selected_buftype = "help" },
    { selected_buftype = "terminal" },

    { target_filetype = "toggleterm" },
    { target_filetype = "neotest-output" },
    { target_filetype = "neotest-summary" },
    { target_filetype = "NvimTree" },
    { target_filetype = "TelescopePrompt" },
    { target_filetype = "DressingInput" },
    { target_filetype = "OverseerList" },
    { target_filetype = "Avante" },
    { target_filetype = "AvanteInput" },
    { target_filetype = "dapui_breakpoints" },
    { target_filetype = "dapui_scopes" },
    { target_filetype = "dapui_breakpoints" },
    { target_filetype = "dapui_stacks" },
    { target_filetype = "dapui_watches" },
    { target_filetype = "dap-repl" },
    { target_filetype = "dapui_console" },
    { target_buftype = 'nofile' },
    { target_buftype = 'prompt' },
    { target_buftype = 'popup' },
    { target_buftype = "help" },
    { target_buftype = "terminal" },
}

M.should_ignore_win = function(target_winid, plugin_name)
    local selected_winid = vim.api.nvim_get_current_win()
    local selected_bufid = vim.api.nvim_win_get_buf(selected_winid)
    local selected_buftype = vim.api.nvim_buf_get_option(selected_bufid, "buftype")
    local selected_buftype = vim.api.nvim_buf_get_option(selected_bufid, "filetype")

    local target_bufid = vim.api.nvim_win_get_buf(target_winid)
    local target_buftype = vim.api.nvim_buf_get_option(target_bufid, "buftype")
    local target_filetype = vim.api.nvim_buf_get_option(target_bufid, "filetype")

    for _, item in ipairs(ignore_list) do
        local rule_matches = (
            item.selected_buftype == selected_buftype
            or item.selected_filetype == selected_filetype
            or item.target_buftype == target_buftype
            or item.target_filetype == target_filetype
        )

        if rule_matches then
            if item[plugin_name] ~= nil then
                return item[plugin_name] == false
            end

            return true
        end
    end

    return false
end

return M
