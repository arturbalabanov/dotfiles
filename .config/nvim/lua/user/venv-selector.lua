local venv_selector = require("venv-selector")

venv_selector.setup {
    name = { "venv", ".venv" },
    changed_venv_hooks = { venv_selector.hooks.pyright }
}

vim.api.nvim_create_autocmd("VimEnter", {
    desc = "Auto select virtualenv Nvim open",
    pattern = "*",
    callback = function()
        local py_project_root_files = {
            "pyproject.toml",
            "Pipfile",
            "requirements.txt",
        }

        local venv_found = false

        for _, filename in ipairs(py_project_root_files) do
            if vim.fn.findfile(filename, vim.fn.getcwd() .. ";") ~= nil then
                venv_found = true
            end
        end

        if venv_found then
            require("venv-selector").retrieve_from_cache()
        end
    end,
    once = true,
})
