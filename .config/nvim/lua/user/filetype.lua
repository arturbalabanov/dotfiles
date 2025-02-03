local ft_settings = require('user.my_plugins.ft_settings')
local my_utils = require('user.utils')

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
    python = {
        win_opts = {
            colorcolumn = function()
                if vim.b.py_venv_info and vim.b.py_venv_info.pyproject_toml then
                    local cmd = "dasel -f " .. vim.b.py_venv_info.pyproject_toml .. " 'tool.ruff.line-length'"
                    local result = my_utils.run_shell_cmd(cmd, { disable_notifications = true, show_error = false })

                    if result then
                        return result
                    end
                end

                return vim.opt.colorcolumn._value
            end
        }
    }
})
