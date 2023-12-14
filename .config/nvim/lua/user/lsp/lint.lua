local lint = require('lint')
local plenary_tbl = require("plenary.tbl")
local my_utils = require("user.utils")
local py_venv = require('user.py_venv')

local function make_py_venv_linter(linter_name, opts)
    opts = plenary_tbl.apply_defaults(opts, { cmd = linter_name, fallback_to_global = false })

    local linter = lint.linters[linter_name]

    linter.cmd = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local venv_cmd_path = py_venv.buf_local_command_path(opts.cmd, bufnr)

        if not my_utils.executable_exists(venv_cmd_path) and opts.fallback_to_global then
            return opts.cmd
        end

        return venv_cmd_path
    end
end

make_py_venv_linter("ruff")
make_py_venv_linter("flake8")
make_py_venv_linter("mypy")
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

lint.linters_by_ft = {
    python = { "ruff", "flake8", "mypy" },
    yaml = { "yamllint" },
    dockerfile = { "hadolint" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    zsh = { "shellcheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "TextChanged" }, {
    group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
    callback = function()
        -- my_utils.timeout(100, lint.try_lint)(nil, { ignore_errors = true })
        lint.try_lint(nil, { ignore_errors = true }) -- nil: all linters
    end,
})
