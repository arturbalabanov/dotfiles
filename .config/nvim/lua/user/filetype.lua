local set_indentation = function(filetype, intentation_length)
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup('IndentationRules', { clear = true }),
        pattern = filetype,
        callback = function()
            vim.opt_local.shiftwidth = intentation_length
            vim.opt_local.tabstop = intentation_length
            vim.opt_local.softtabstop = intentation_length
        end
    })
end

set_indentation("terraform", 2)
-- set_indentation("yaml", 2)
