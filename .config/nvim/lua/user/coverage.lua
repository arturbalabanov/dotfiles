require("coverage").setup({
    summary = {
        -- customize the summary pop-up
        min_coverage = 95.0, -- minimum coverage threshold (used for highlighting)
    },
    commands = true,         -- create commands
    -- highlights = {
    -- 	-- customize highlight groups created by the plugin
    -- 	covered = { fg = "#C3E88D" },   -- supports style, fg, bg, sp (see :h highlight-gui)
    -- 	uncovered = { fg = "#F07178" },
    -- },
    -- signs = {
    -- 	-- use your own highlight groups or text markers
    -- 	covered = { hl = "CoverageCovered", text = "▎" },
    -- 	uncovered = { hl = "CoverageUncovered", text = "▎" },
    -- },
    lang = {
        python = {
            coverage_file = '.coverage'
        }
        -- customize language specific settings
    },
})
