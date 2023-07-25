local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
    return
end

local my_utils = require("user.utils")
local lsp_common = require("user.lsp.common")
local py_venv = require("user.py_venv")


-- ref: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

local temp_dir = vim.loop.os_getenv("TEMP") or "/tmp"

local local_source_per_buffer = function(source)
    return source.with({
        env = function(params)
            local venv_info = py_venv.get_python_venv(params.bufnr, { disable_notifications = true })

            if venv_info == nil then
                return nil
            end

            return {
                PYTHONPATH = venv_info.python_path,
                PATH = venv_info.bin_path,
            }
        end,
        cwd = function(params)
            local found, project_root = pcall(vim.api.nvim_buf_get_var, params.bufnr, "project_root")
            if not found then
                return nil
            end

            return project_root
        end,
        only_local = '.venv/bin',
        -- condition = function(utils) return false end,
    })
end

null_ls.setup({
    sources = {
        -- diagnostics
        local_source_per_buffer(null_ls.builtins.diagnostics.ruff),
        local_source_per_buffer(null_ls.builtins.diagnostics.flake8),
        local_source_per_buffer(null_ls.builtins.diagnostics.mypy),

        -- formatting
        local_source_per_buffer(null_ls.builtins.formatting.ruff),
        local_source_per_buffer(null_ls.builtins.formatting.black),
        local_source_per_buffer(null_ls.builtins.formatting.isort),
    },
    on_attach = lsp_common.on_attach,
    temp_dir = temp_dir,
})
