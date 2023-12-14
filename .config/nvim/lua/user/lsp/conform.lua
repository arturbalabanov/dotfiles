local py_venv = require('user.py_venv')

local function py_venv_formatter(command)
    return function(bufnr)
        return {
            command = py_venv.buf_local_command_path(command, bufnr)
        }
    end
end

-- TODO: add yammlfix

require("conform").setup({
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
    },
    formatters = {
        ruff = py_venv_formatter("ruff"),
        isort = py_venv_formatter("isort"),
        black = py_venv_formatter("black"),
    },
    formatters_by_ft = {
        python = { "ruff", "isort", "black" },
        markdown = { "inject" },
        ["*"] = { "codespell" },
    },
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
