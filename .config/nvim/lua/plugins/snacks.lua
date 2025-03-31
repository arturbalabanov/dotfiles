return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- ref: https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
        ---@class snacks.dashboard.Config
        ---@field enabled? boolean
        ---@field sections snacks.dashboard.Section
        ---@field formats table<string, snacks.dashboard.Text|fun(item:snacks.dashboard.Item, ctx:snacks.dashboard.Format.ctx):snacks.dashboard.Text>
        dashboard = {
            enabled = true,
            width = 100,
            sections = {
                { section = "header" },
                { section = "startup" },
                {
                    icon = " ",
                    title = "Quick Actions",
                    section = "keys",
                    indent = 2,
                    padding = 1,
                },
                {
                    icon = " ",
                    title = "Recent Project Files",
                    section = "recent_files",
                    indent = 2,
                    padding = 1,
                    cwd = true,
                    limit = 5,
                },
                function()
                    local in_git = Snacks.git.get_root() ~= nil
                    local cmds = {
                        {
                            icon = " ",
                            title = "Git Status",
                            cmd = "git --no-pager diff --stat -B -M -C",
                            key = "S",
                            action = function()
                                vim.cmd.DiffviewOpen()
                            end,
                            height = 10,
                        },
                    }
                    return vim.tbl_map(function(cmd)
                        return vim.tbl_extend("force", {
                            section = "terminal",
                            enabled = in_git,
                            padding = 1,
                            ttl = 5 * 60,
                            indent = 2,
                        }, cmd)
                    end, cmds)
                end,
            },
        },
    },
}
