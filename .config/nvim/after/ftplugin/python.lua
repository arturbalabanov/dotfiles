vim.cmd([[setlocal colorcolumn=120]])
vim.cmd([[setlocal textwidth=120]])

vim.b.minisurround_config = {
    custom_surroundings = {
        l = { output = { left = 'lambda: ', right = '' } },
    }
}
