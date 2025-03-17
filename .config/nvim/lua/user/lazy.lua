-- Install lazy.nvim if not already installed {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})

        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)
-- }}}

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
    return
end

-- Plugins {{{
return lazy.setup {
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
            { "<leader>R", function() require("live-rename").rename({ text = "", insert = true }) end, desc = "LSP rename" },
        },
    },

    {
        'nvim-tree/nvim-web-devicons',
        tag = 'nerd-v2-compat',
        lazy = true,
    },

    "onsails/lspkind.nvim",

    {
        -- TODO: replace with stevanmilic/nvim-lspimport once #7 is merged:
        --       https://github.com/stevanmilic/nvim-lspimport/pull/7
        'arturbalabanov/nvim-lspimport',
        branch = "add-missing-imports",
        keys = {
            { '<leader>i', function() require("lspimport").import() end, desc = "Import symbol under cursor" },
        }
    },

    -- TODO: this is a fork of AckslD/nvim-pytrize.lua, replace with original once PR is merged
    --       https://github.com/AckslD/nvim-pytrize.lua/pull/10
    {
        "Nosterx/nvim-pytrize.lua",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        opts = {},
        ft = { "python" },
        keys = {
            {
                "gf",
                function() require("user.utils").move_jump_to_new_tab(vim.cmd.PytrizeJumpFixture) end,
                desc = "Go To Pytest fixture defintion",
            },
        }
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

    {
        "saifulapm/commasemi.nvim",
        keys = {
            { "<localleader>,", desc = "Toggle comma" },
            { "<localleader>;", desc = "Toggle semicolon" },
        },
        opts = {
            leader = '<localleader>',
            keymaps = true,
            commands = true,
        },
    },

    -- Markdown {{{
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ft = { 'markdown', 'md', 'Avante', 'quarto' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            file_types = { 'markdown', 'md', 'Avante', 'quarto' },
        }
    },
    -- }}}
}
-- }}}
