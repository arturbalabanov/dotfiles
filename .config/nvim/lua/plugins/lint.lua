-- ref: https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters

return {
    "mfussenegger/nvim-lint",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
        lint_on_events = { "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" },
        linters_by_ft = {
            python = { "ruff", "flake8", "mypy", "bandit" },
            yaml = { "yamllint" },
            dockerfile = { "hadolint" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
            zsh = { "shellcheck" },
            proto = { "buf_lint" },
        },
        py_venv_linters = {
            { name = "ruff" },
            { name = "flake8" },
            { name = "mypy" },
            { name = "yamllint", fallback_to_global = true },
            {
                name = "bandit",
                args = {
                    "-f",
                    "custom",
                    "--msg-template",
                    "{line}:{col}:{severity}:{test_id} {msg}",
                    "-c",
                    function() return "pyproject.toml" end
                }
            },
        },
    },
    config = function(_, opts)
        local lint = require('lint')
        local plenary_tbl = require("plenary.tbl")
        local my_utils = require("user.utils")
        local py_venv = require('user.py_venv')

        local function make_py_venv_linter(linter_name, opts)
            opts = plenary_tbl.apply_defaults(opts, { cmd = linter_name, fallback_to_global = false, args = nil })

            local linter = lint.linters[linter_name]

            linter.cmd = function()
                local bufnr = vim.api.nvim_get_current_buf()
                local venv_cmd_path = py_venv.buf_local_command_path(opts.cmd, bufnr)

                if my_utils.executable_exists(venv_cmd_path) then
                    return venv_cmd_path
                end

                if opts.fallback_to_global then
                    return opts.cmd
                end
            end

            if opts.args ~= nil then
                linter.args = opts.args
            end
        end

        for _, linter in ipairs(opts.py_venv_linters) do
            make_py_venv_linter(linter.name, linter)
        end

        lint.linters_by_ft = opts.linters_by_ft

        vim.api.nvim_create_autocmd(opts.lint_on_events, {
            group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
            callback = function()
                -- my_utils.timeout(100, lint.try_lint)(nil, { ignore_errors = true })
                lint.try_lint(nil, { ignore_errors = true }) -- nil: all linters
            end,
        })
    end
}
