local lint = require('lint')
local plenary_tbl = require("plenary.tbl")
local my_utils = require("user.utils")
local py_venv = require('user.py_venv')

local function make_py_venv_linter(linter_name, opts)
    opts = plenary_tbl.apply_defaults(opts, { cmd = linter_name, fallback_to_global = false, additional_config = nil })

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
end

make_py_venv_linter("ruff")
make_py_venv_linter("flake8")
make_py_venv_linter("mypy")
make_py_venv_linter("bandit")

-- TODO: This is a big hack, refactor and make it smart
-- {
--     additional_config = function(linter)
--         local super_args = linter.args
--
--         linter.args = function()
--             local orig_args
--
--             if type(super_args) == "function" then
--                 orig_args = super_args()
--             else
--                 orig_args = super_args
--             end
--
--             if vim.tbl_contains(orig_args, "-c") then
--                 return orig_args
--             end
--
--             local bufnr = vim.api.nvim_get_current_buf()
--             local venv = py_venv.get_python_venv(bufnr, { disable_notifications = true })
--
--             if not venv or not venv.pyproject_toml then
--                 return orig_args
--             end
--
--             return vim.tbl_deep_extend("force", orig_args, { "-c", venv.pyproject_toml })
--         end
--     end
-- })
lint.linters.bandit.args = {
    "-f",
    "custom",
    "--msg-template",
    "{line}:{col}:{severity}:{test_id} {msg}",
    "-c",
    function() return "pyproject.toml" end
}
make_py_venv_linter("yamllint", { fallback_to_global = true })

-- TODO: Add * linters (applicable to all filetypes) and _ linters (applicable only when no other
-- linter is set)

-- TODO: Add the following linters:
--       * dotenv
--       * editorconfig-checker
--       * cmakelint
--       * spellcheck
--       * markdownlint
--       * inject
--       * vale

-- ref:
-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters

lint.linters_by_ft = {
    python = { "ruff", "flake8", "mypy", "bandit" },
    yaml = { "yamllint" },
    dockerfile = { "hadolint" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    zsh = { "shellcheck" },
    proto = { "buf_lint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
    group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
    callback = function()
        -- my_utils.timeout(100, lint.try_lint)(nil, { ignore_errors = true })
        lint.try_lint(nil, { ignore_errors = true }) -- nil: all linters
    end,
})
