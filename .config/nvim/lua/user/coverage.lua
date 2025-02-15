require("coverage").setup({
    summary = {
        min_coverage = 95.0, -- used for highlighting
    },
    commands = true,
    auto_reload = true,
    lang = {
        python = {
            coverage_file = '.coverage'
        }
    },
})
