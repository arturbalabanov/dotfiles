local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
    return
end

local my_utils = require("user.utils")
local lsp_common = require("user.lsp.common")

local temp_dir = vim.loop.os_getenv("TEMP") or "/tmp"


local local_source_per_buffer = function(source, executable)
    return source.with({
        condition = function(utils)
            return my_utils.executable_exists(executable)
        end,
        prefer_local = true,
    })
end

null_ls.setup({
    sources = {
        -- diagnostics
        local_source_per_buffer(null_ls.builtins.diagnostics.ruff, "ruff"),
        local_source_per_buffer(null_ls.builtins.diagnostics.flake8, "flake8"),
        local_source_per_buffer(null_ls.builtins.diagnostics.mypy, "mypy"),

        -- formatting
        local_source_per_buffer(null_ls.builtins.formatting.ruff, "ruff"),
        local_source_per_buffer(null_ls.builtins.formatting.black, "black"),
        local_source_per_buffer(null_ls.builtins.formatting.isort, "isort"),
    },
    on_attach = lsp_common.on_attach,
    temp_dir = temp_dir,
})
