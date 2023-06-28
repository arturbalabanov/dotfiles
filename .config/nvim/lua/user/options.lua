local opt = vim.opt

-- basics
opt.backup = false
opt.swapfile = false
opt.writebackup = false -- don't allow to write to protected files (currently editted by another program)
opt.clipboard = "unnamedplus"
opt.fileencoding = "utf-8"
opt.undofile = true

-- UI
opt.termguicolors = true
opt.showmode = false
opt.ruler = false
opt.cmdheight = 1
opt.cursorline = true
opt.colorcolumn = "130"
opt.number = false
opt.signcolumn = "yes"
opt.numberwidth = 4
opt.scrolloff = 8
opt.mouse = "a"
opt.splitbelow = true
opt.splitright = true
opt.completeopt = { 'menu', 'menuone', 'preview' }
opt.updatetime = 300 -- faster completion (4000ms default)
opt.laststatus = 3   -- Make the statusline global

-- text
opt.wrap = false
opt.spell = false
opt.textwidth = 100
opt.whichwrap:append("<,>,[,],h,l")         -- keys allowed to move to the previous/next line when the beginning/end of line is reached
opt.iskeyword:append("-")                   -- treats words with `-` as single words
opt.iskeyword:remove(":")                   -- make sure words seperated by `:` are treated as different words
opt.formatoptions:remove({ "c", "r", "o" }) -- This is a sequence of letters which describes how automatic formatting is to be done

-- indentation
opt.smartindent = true
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- folding
opt.foldenable = false

-- other
opt.wildignore:append('*.pyc')
opt.wildignore:append('*.pyo')
opt.wildignore:append('*.so')
opt.wildignore:append('*.o')
opt.wildignore:append('__pycache__')
opt.wildignore:append('**/.git/**')
opt.wildignore:append('.coverage')
opt.wildignore:append('**/node_modules/**')
opt.wildignore:append('.idea')
opt.wildignore:append('*.png')
opt.wildignore:append('*.jpeg')
opt.wildignore:append('*.pdf')
opt.wildignore:append('*.svg')
opt.wildignore:append('**/__vcr_cassettes__/**')
opt.wildignore:append('**/.pytest_cache/**')
opt.wildignore:append('.ruff_cache')
opt.wildignore:append('.pdm-build')
opt.wildignore:append('**/.mypy_cache/**')

-- disable netrw because we use nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Python support
-- local py_venv_path = vim.fn.system {
--    'poetry',
--    'env',
--    'info',
--    '-p',
--    '-C',
--    vim.fn.stdpath("config"),
--    }:gsub("%s*$", "")
-- vim.g.python3_host_prog = py_venv_path .. '/bin/python'

vim.cmd [[
    augroup highlight_on_yank_user
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="Search", timeout=100}
    augroup end
]]

vim.api.nvim_create_user_command('Redir', function(ctx)
    local lines = vim.split(vim.api.nvim_exec(ctx.args, true), '\n', { plain = true })
    vim.cmd.new()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.opt_local.modified = false
end, { nargs = '+', complete = 'command' })
