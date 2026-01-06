-- Install lazy.nvim if not already installed {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})

        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)
-- }}}
-- lazy.nvim configuration {{{

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
    return
end

local lazy_config = {
    dev = {
        -- Directory where you store your local plugin projects. If a function is used,
        -- the plugin directory (e.g. `~/projects/plugin-name`) must be returned.
        ---@type string | fun(plugin: LazyPlugin): string
        path = "~/dev/side",
        ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
        patterns = {}, -- For example {"folke"}
        fallback = true, -- Fallback to git when local plugin doesn't exist
    },
}

-- }}}
-- Plugins {{{
local plugin_specs = {
    { import = "plugins" },
    { import = "plugins.mini" },
    { import = "plugins.git" },
    { import = "plugins.ai" },
    { import = "plugins.focus" },

    { "nvim-lua/plenary.nvim", lazy = true },
    {
        "saecki/live-rename.nvim",
        opts = {
            hl = {
                current = "Normal",
                others = "Search",
            },
        },
        keys = {
            {
                "<leader>R",
                function()
                    require("live-rename").rename({ text = "", insert = true })
                end,
                desc = "LSP rename",
            },
        },
    },

    {
        "nvim-tree/nvim-web-devicons",
        tag = "nerd-v2-compat",
        lazy = true,
    },

    "onsails/lspkind.nvim",

    -- TODO: this is a fork of AckslD/nvim-pytrize.lua, replace with original once PR is merged
    --       https://github.com/AckslD/nvim-pytrize.lua/pull/10
    {
        "Nosterx/nvim-pytrize.lua",
        -- TODO: Re-enable
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        opts = {},
        ft = { "python" },
        keys = {
            {
                "gf",
                function()
                    require("utils").move_jump_to_new_tab(vim.cmd.PytrizeJumpFixture)
                end,
                desc = "Go To Pytest fixture defintion",
            },
        },
    },

    -- TODO: Enable this plugin once you have time to configure it (smooth scrolling)
    -- {
    --     "declancm/cinnamon.nvim",
    --     version = "*", -- use latest release
    --     opts = {
    --         -- Enable all provided keymaps
    --         keymaps = {
    --             basic = true,
    --             extra = true,
    --         },
    --     },
    -- },

    "RRethy/nvim-treesitter-endwise",

    {
        "saifulapm/commasemi.nvim",
        keys = {
            { "<localleader>,", desc = "Toggle comma" },
            { "<localleader>;", desc = "Toggle semicolon" },
        },
        opts = {
            leader = "<localleader>",
            keymaps = true,
            commands = true,
        },
    },

    -- WARN: Do not lazy load this plugin as it is already lazy-loaded.
    -- Lazy-loading will cause more time for the previews to load when starting Neovim.
    {
        "OXY2DEV/helpview.nvim",
        lazy = false,
        dependencies = "nvim-web-devicons",
        opts = {
            preview = {
                icon_provider = "devicons",
            },
        },
    },

    {
        "meznaric/key-analyzer.nvim",
        opts = {},
        cmd = { "KeyAnalyzer" },
    },
}
-- }}}
-- Run lazy.nvim setup {{{
lazy_config.spec = plugin_specs

return lazy.setup(lazy_config)
-- }}}
-- vim:foldmethod=marker
