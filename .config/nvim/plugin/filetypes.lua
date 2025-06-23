vim.filetype.add {
    extension = {
        fountain = 'fountain',
        jinja = 'jinja2',
        jinja2 = 'jinja2',
        service = "systemd",
    },
    pattern = {
        -- match .env, .env.local, etc.
        ["%.env%.%w+"] = 'sh',
        -- special case env.example too (don't make it too generic
        -- so that it doesn't match env.py for example)
        ["env%.example"] = 'sh',
        -- match Dockerfile.local, Dockerfile.dev, etc.
        ["Dockerfile%.%w+"] = 'dockerfile',
        -- match Dockerfile_local, Dockerfile_dev, etc.
        ["Dockerfile_%w+"] = 'dockerfile',
    }
}
