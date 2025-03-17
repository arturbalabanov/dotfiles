vim.filetype.add {
    extension = {
        fountain = 'fountain',
        jinja = 'jinja2',
        jinja2 = 'jinja2',
    },
    pattern = {
        -- match .env, .env.local, etc.
        ["%.env%.%w+"] = 'sh',
        -- special case env.example too (don't make it too generic
        -- so that it doesn't match env.py for example)
        ["env%.example"] = 'sh',
    }
}
