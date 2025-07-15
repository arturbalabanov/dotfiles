-- Copied these from the jinja2 config as ansible uses a mix of Jinja2 and YAML
-- Ideally this should be configured using treesitter nested languages but this
-- is good enough for now

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
