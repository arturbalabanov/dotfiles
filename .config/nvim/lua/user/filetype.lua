local ft_options = {
    zsh = {
        foldmethod = 'marker',
    }
}

-- NOTE: Replaced by guess_indent
--
-- local ft_indentation = {
--     lua = 4,
--     terraform = 2,
--     yaml = 2,
-- }
--
-- for filetype, indent_size in pairs(ft_indentation) do
--     ft_options[filetype] = ft_options[filetype] or {}
--     ft_options[filetype].tabstop = indent_size
--     ft_options[filetype].shiftwidth = indent_size
--     ft_options[filetype].softtabstop = indent_size
-- end

for filetype, options in pairs(ft_options) do
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup('UserFileTypeSpecificOptions', { clear = false }),
        pattern = filetype,
        callback = function()
            for option, value in pairs(options) do
                vim.opt_local[option] = value
            end
        end
    })
end
