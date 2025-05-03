return {
    "otavioschwanck/arrow.nvim",
    dependencies = {
        { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
        show_icons = true,
        leader_key = '-',        -- Recommended to be a single key
        buffer_leader_key = '=', -- Per Buffer Mappings
        mappings = {
            toggle = "-",        -- used as save if separate_save_and_remove is true
            open_vertical = "v",
            open_horizontal = "s",
        },
    },
}
