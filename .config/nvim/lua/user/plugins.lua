-- Automatically install packer
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

packer.init {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end,
    },
    git = {
        clone_timeout = 300, -- Timeout, in seconds, for git clones
    },
}

return packer.startup(function(use)
    use "wbthomason/packer.nvim"
    use 'lewis6991/impatient.nvim'
    use 'nvim-lua/plenary.nvim'

    use "neovim/nvim-lspconfig"
    -- TODO: Remove mason
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "jose-elias-alvarez/null-ls.nvim"
    use "jay-babu/mason-null-ls.nvim"

    use { 'echasnovski/mini.nvim' }
    use { "ellisonleao/gruvbox.nvim" }

    use "tpope/vim-fugitive"
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
        },
        tag = 'nightly'
    }

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons'
        }
    }

    use {
        "pschmitt/telescope-yadm.nvim",
        requires = "nvim-telescope/telescope.nvim",
    }

    use {
        "nvim-telescope/telescope-live-grep-args.nvim",
        requires = "nvim-telescope/telescope.nvim",
    }

    use({
        "aaronhallaert/advanced-git-search.nvim",
        requires = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-fugitive", -- to show diff splits and open commits in browser
            "tpope/vim-rhubarb",  -- to open commits in browser with fugitive
            -- optional: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            -- "sindrets/diffview.nvim",
        },
    })
    use {
        "nvim-telescope/telescope-frecency.nvim",
        requires = {
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope.nvim",
        }
    }
    use {
        "ghassan0/telescope-glyph.nvim",
        requires = {
            'nvim-tree/nvim-web-devicons',
            "nvim-telescope/telescope.nvim",
        }
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end
    }

    use {
        'nvim-treesitter/playground'
    }

    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    }

    use {
        "lukas-reineke/indent-blankline.nvim",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("indent_blankline").setup {
                buftype_exclude = { "terminal" },
                show_current_context = true,
                -- show_current_context_start = true,
            }
        end
    }

    use 'onsails/lspkind.nvim'
    use "folke/neodev.nvim"

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'

    use "rafamadriz/friendly-snippets"
    use({
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v1.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        run = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
    })
    use 'saadparwaiz1/cmp_luasnip'

    use 'ray-x/lsp_signature.nvim'
    use 'KostkaBrukowa/definition-or-references.nvim'

    use {
        "folke/trouble.nvim",
        requires = "nvim-tree/nvim-web-devicons",
    }

    use "darfink/vim-plist"
    use 'glepnir/lspsaga.nvim'
    use "rmagatti/goto-preview"

    use {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
    }

    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim"
        }
    }
    use {
        "nvim-neotest/neotest-python",
        requires = {
            "nvim-neotest/neotest",
            "nvim-treesitter/nvim-treesitter",
        },
    }
    use { "akinsho/toggleterm.nvim", tag = '*' }
    use "chentoast/marks.nvim"

    use {
        "rcarriga/nvim-notify",
        config = function() vim.notify = require("notify") end,
    }

    use {
        "folke/noice.nvim",
        requires = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify", 'nvim-treesitter/nvim-treesitter', }
    }

    use "rebelot/heirline.nvim"
    use "lewis6991/gitsigns.nvim"
    use "ahmedkhalf/project.nvim"
    use({
        "jackMort/ChatGPT.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    })
    use "declancm/cinnamon.nvim"
    use "sindrets/diffview.nvim"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
