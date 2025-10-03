vim.opt_local.commentstring = "{{/* %s */}}"
vim.b.minisurround_config = {
    custom_surroundings = {
        v = {
            output = { left = "{{ ", right = " }}" },
        },
    },
}
