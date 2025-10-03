return {
    "rmagatti/auto-session",
    lazy = false,
    enabled = false,

    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "/" },
    },
}
