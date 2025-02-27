-- Automatically install packer {{{
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
-- }}}

local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Packer config {{{
packer.init {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end,
    },
    git = {
        clone_timeout = 300, -- Timeout, in seconds, for git clones
    },
    autoremove = true,       -- Automatically remove unused dependencies
}
-- }}}

-- Plugins {{{
return packer.startup(function(use)
    use "wbthomason/packer.nvim"
    use 'lewis6991/impatient.nvim'
    use 'nvim-lua/plenary.nvim'

    use "neovim/nvim-lspconfig"
    use "mfussenegger/nvim-lint"
    use "stevearc/conform.nvim"

    use "max397574/better-escape.nvim"

    use { 'echasnovski/mini.nvim' }

    --- Themes {{{
    use { "ellisonleao/gruvbox.nvim" }
    use { "folke/tokyonight.nvim" }
    use { "EdenEast/nightfox.nvim" }
    use { "tiagovla/tokyodark.nvim" }
    use { "scottmckendry/cyberdream.nvim" }
    --- }}}

    use {
        'nvim-tree/nvim-web-devicons',
        tag = 'nerd-v2-compat',
    }
    use {
        'nvim-tree/nvim-tree.lua',
        tag = 'nvim-tree-v1.2.0'
    }

    use 'stevearc/dressing.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
    }
    use {
        "ghassan0/telescope-glyph.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
    }

    use {
        "FabianWirth/search.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
    }


    -- Git {{{
    use "tpope/vim-fugitive"

    use {
        "aaronhallaert/advanced-git-search.nvim",
        requires = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-fugitive", -- to show diff splits and open commits in browser
            "tpope/vim-rhubarb",  -- to open commits in browser with fugitive
            -- optional: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            "sindrets/diffview.nvim",
        },
    }
    use "sindrets/diffview.nvim"
    use "lewis6991/gitsigns.nvim"
    use {
        "purarue/gitsigns-yadm.nvim",
        requires = {
            "lewis6991/gitsigns.nvim",
        },
    }
    use {
        "pschmitt/telescope-yadm.nvim",
        requires = "nvim-telescope/telescope.nvim",
    }
    use {
        'pwntester/octo.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'nvim-tree/nvim-web-devicons',
        },
    }
    -- }}}

    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }

    use {
        "kevinhwang91/nvim-bqf",
        ft = 'qf',
    }

    -- TODO: remove me as this is now built-in
    use 'nvim-treesitter/playground'

    use 'Wansmer/treesj'

    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
    }

    use {
        "lukas-reineke/indent-blankline.nvim",
        after = "nvim-treesitter",
        tag = "v2.20.8",
    }

    use 'onsails/lspkind.nvim'

    -- TODO: neodev has reached EoL, replace it with folke/lazydev.nvim
    use "folke/neodev.nvim"

    -- Autocomplete (incl. snippets) {{{
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'

    use {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v1.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        run = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
        }
    }
    use 'saadparwaiz1/cmp_luasnip'
    use {
        "chrisgrieser/nvim-scissors",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "nvim-telescope/telescope.nvim",
        }
    }
    use "rafamadriz/friendly-snippets"
    -- }}}
    use {
        -- TODO: replace with stevanmilic/nvim-lspimport once #7 is merged:
        --       https://github.com/stevanmilic/nvim-lspimport/pull/7
        'arturbalabanov/nvim-lspimport',
        branch = "add-missing-imports",
    }

    use "gbprod/substitute.nvim"

    -- TODO: remove me, I don't think it's being used atm (config in lsp/common.lua)
    use 'ray-x/lsp_signature.nvim'
    use 'KostkaBrukowa/definition-or-references.nvim'

    use "folke/trouble.nvim"
    use "folke/todo-comments.nvim"

    use "chrisgrieser/nvim-rulebook"

    use "darfink/vim-plist"
    use {
        'nvimdev/lspsaga.nvim',
        after = 'nvim-lspconfig',
    }
    use "rmagatti/goto-preview"

    -- Testing {{{
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-neotest/nvim-nio",
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
    use {
        "andythigpen/nvim-coverage",
        requires = {
            "nvim-lua/plenary.nvim",
        }
    }
    -- }}}

    -- automatically convert strings to f-strings in python (and similar in other languages)
    use "chrisgrieser/nvim-puppeteer"

    -- folding with nvim-ufo
    use {
        'kevinhwang91/nvim-ufo',
        requires = {
            'kevinhwang91/promise-async',
        },
    }

    use { "akinsho/toggleterm.nvim", tag = '*' }
    use "chentoast/marks.nvim"

    use {
        "rcarriga/nvim-notify",
        config = function() vim.notify = require("notify") end,
    }

    use "stevearc/overseer.nvim"

    -- Debugging {{{
    use "mfussenegger/nvim-dap"
    use {
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    }
    use {
        "mfussenegger/nvim-dap-python",
        requires = {
            "mfussenegger/nvim-dap"
        }
    }
    -- }}}

    use {
        "folke/noice.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
            'nvim-treesitter/nvim-treesitter',
        }
    }

    use "rebelot/heirline.nvim"
    use {
        "b0o/incline.nvim",
        requires = {
            "nvim-tree/nvim-web-devicons",
        }
    }
    use "ahmedkhalf/project.nvim"


    use {
        "ThePrimeagen/refactoring.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter"
        }
    }

    use {
        "MagicDuck/grug-far.nvim",
        requires = {
            "nvim-tree/nvim-web-devicons",
        },
    }

    -- AI {{{
    use {
        "jackMort/ChatGPT.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    }

    use {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function() require("user.ai.copilot") end
    }

    use {
        "yetone/avante.nvim",
        requires = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            -- "zbirenbaum/copilot.lua", -- for providers='copilot'  -- TODO: re-enable
            "HakonHarnes/img-clip.nvim", -- support for image pasting
            "MeanderingProgrammer/render-markdown.nvim",
        },
        run = "make",
        config = function()
            require('avante_lib').load()
        end,
    }
    -- }}}

    use "declancm/cinnamon.nvim"
    use "nmac427/guess-indent.nvim"
    use "beauwilliams/focus.nvim"
    use "levouh/tint.nvim"
    use "Pocco81/true-zen.nvim"

    use {
        "saifulapm/commasemi.nvim",
        config = function()
            require('commasemi').setup({
                leader = ',',
                keymaps = true,
                commands = true
            })
        end
    }

    -- Markdown {{{
    local md_file_types = { 'markdown', 'md', 'Avante', 'quarto' }
    use {
        'MeanderingProgrammer/render-markdown.nvim',
        after = { 'nvim-treesitter' },
        requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        ft = md_file_types,
        config = function()
            require('render-markdown').setup {
                file_types = md_file_types,
            }
        end
    }
    -- }}}

    use "Aasim-A/scrollEOF.nvim"

    use "pearofducks/ansible-vim"

    use "aserowy/tmux.nvim"
    use { 'mistricky/codesnap.nvim', run = 'make' }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
-- }}}
