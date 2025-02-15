vim.bo.commentstring = "{# %s #}"
vim.b.minisurround_config = {
    custom_surroundings = {
        v = {
            output = { left = '{{ ', right = ' }}' },
        },
        e = {
            output = { left = '{% ', right = ' %}' },
        },
    },
}
