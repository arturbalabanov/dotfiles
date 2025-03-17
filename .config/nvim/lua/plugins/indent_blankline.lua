return {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    main = "ibl",
    opts = {
        exclude = {
            filetypes = {
                "markdown",
                "md",
                "Avante",
                "Trouble",
                "alpha",
                "dashboard",
                "help",
                "lazy",
                "mason",
                "neo-tree",
                "notify",
                "snacks_dashboard",
                "snacks_notif",
                "snacks_terminal",
                "snacks_win",
                "toggleterm",
                "trouble",
            },
            buftypes = {
                "terminal",
                "nofile",
            },
        },
        scope = { show_start = false, show_end = false },
    },
}
