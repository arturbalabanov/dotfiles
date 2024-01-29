local ft_settings = require('user.my_plugins.ft_settings')

-- Note on foldmethod: there is an autocmd in treesitter.lua that sets foldmethod to 'expr' for
-- on BufEnter, BufAdd, BufNew, BufNewFile, BufWinEnter, so I special cased 'marker' there to ignore
-- it as a quick workarround, if setting other foldmethods in filetype.lua, this needs to be updated
-- Also see https://vi.stackexchange.com/a/36593 for the autocmd order, seems the treesitter augroup
-- needs to be updated anyway due to the autocmd order

ft_settings.setup({
    zsh = {
        win_opts = {
            foldmethod = 'marker',
        },
    },
    jinja2 = {
        buf_opts = {
            commentstring = '{# %s #}',
        },
        buf_vars = {
            minisurround_config = {
                custom_surroundings = {
                    v = {
                        output = { left = '{{ ', right = ' }}' },
                    },
                    e = {
                        output = { left = '{% ', right = ' %}' },
                    },
                },
            },
        }
    },
    fountain = {
        win_opts = {
            colorcolumn = "36"
        },
        buf_opts = {
            textwidth = 36
        },
    },
})
