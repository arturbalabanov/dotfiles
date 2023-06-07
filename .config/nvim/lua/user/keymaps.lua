local cmd = vim.cmd
local utils = require("user.utils")

-- Use Space as a leader key
vim.g.mapleader = ' '

utils.ikeymap("jj", "<Esc>")
utils.nkeymap(";", ":", { silent = false })

-- Use vv to select current line without leading and trailing indentation
utils.nkeymap("vv", "^vg_")

-- Reselect visual block after indent/dedent
utils.vkeymap("<", "<gv")
utils.vkeymap(">", ">gv")

-- Easily go to the beginning/end of the line
utils.nkeymap("H", "^")
utils.vkeymap("H", "^")
utils.nkeymap("L", "$")
utils.vkeymap("L", "g_")

-- Toggle folds with <Tab>
utils.nkeymap("<Tab>", "za")

-- Toggle the line numbers with <F1>
utils.nkeymap("<F1>", ":set invnumber<CR>")

-- Clear highlight search with ,/
utils.nkeymap(",/", cmd.nohlsearch)

-- Move between windows and tabs
utils.nkeymap("gh", function() cmd.wincmd("h") end)
utils.nkeymap("gj", function() cmd.wincmd("j") end)
utils.nkeymap("gk", function() cmd.wincmd("k") end)
utils.nkeymap("gl", function() cmd.wincmd("l") end)
utils.nkeymap("K", cmd.tabn)
utils.nkeymap("J", cmd.tabp)


--- Reload the entire configuration
local reload_config = function()
    for name, _ in pairs(package.loaded) do
        if name:match('^user') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)

    -- Reload after/ directory
    local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(glob, true, true)

    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end

    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('ReloadConfig', reload_config, { nargs = 0 })
