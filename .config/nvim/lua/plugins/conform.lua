local my_utils = require("utils")

local function py_venv_formatter(formatter_name)
    local status_ok, formatter_module = pcall(require, "conform.formatters." .. formatter_name)

    if not status_ok then
        my_utils.error_fmt("Formatter '%s' not found in the conform.nvim formatters repo", formatter_name)
        return
    end

    local formatter_conf = vim.deepcopy(formatter_module)
    local original_command = formatter_module.command

    -- TODO: Check if formatter_conf is a function and evaluate it
    --       (there is probably a utility function for that in conform.nvim)

    return function(bufnr)
        formatter_conf.command = require('user.py_venv').buf_local_command_path(original_command, bufnr)
        return formatter_conf
    end
end

-- ref:
-- https://github.com/stevearc/conform.nvim/tree/master/lua/conform/formatters

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = function()
        return {
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end

                return {
                    -- These options will be passed to conform.format()
                    timeout_ms = 800,
                    lsp_fallback = true,
                }
            end,
            formatters = {
                ruff_fix = py_venv_formatter("ruff_fix"),
                ruff_format = py_venv_formatter("ruff_format"),
                isort = py_venv_formatter("isort"),
                black = py_venv_formatter("black"),
            },
            formatters_by_ft = {
                python = { "ruff_fix", "ruff_format", "isort", "black" },
                markdown = { "inject" },
                proto = { "buf" },
                ["*"] = { "codespell" },
            },
        }
    end,
    init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
