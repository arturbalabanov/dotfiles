" Visual Studio Code {{{
    if exists('g:vscode')
        inoremap jj <Esc>
        nnoremap vv ^vg_

        nnoremap ; :

        " Switching between tabs
        nnoremap K :Tabnext<CR>
        nnoremap J :Tabprevious<CR>

        " Reselect visual block after indent/dedent
        vnoremap < <gv
        vnoremap > >gv

        " Easily go to the beginning/end of the line
        noremap H ^
        noremap L $
        vnoremap L g_

        nnoremap zM :call VSCodeNotify('editor.foldAll')<CR>
        nnoremap zR :call VSCodeNotify('editor.unfoldAll')<CR>
        nnoremap zc :call VSCodeNotify('editor.fold')<CR>
        nnoremap zC :call VSCodeNotify('editor.foldRecursively')<CR>
        nnoremap zo :call VSCodeNotify('editor.unfold')<CR>
        nnoremap zO :call VSCodeNotify('editor.unfoldRecursively')<CR>
        nnoremap za :call VSCodeNotify('editor.toggleFold')<CR>
        nnoremap <space> :call VSCodeNotify('editor.toggleFold')<CR>
        
        function! MoveCursor(direction) abort
            if(reg_recording() == '' && reg_executing() == '')
                return 'g'.a:direction
            else
                return a:direction
            endif
        endfunction
        
        nmap <expr> j MoveCursor('j')
        nmap <expr> k MoveCursor('k')

        " Copy/paste from the clipboard. For Windows/Mac use: set clipboard=unnamed
        set clipboard+=unnamedplus

        finish
    endif
" }}}
" Basic options {{{
    filetype off

    " Python support
    let g:python_host_prog='/usr/bin/python2'
    let g:python3_host_prog='/usr/bin/python3'

    " Map the leader keys
    let mapleader=","
    let maplocalleader="\\"

    set nowrap

    " Use the backspace key as expected
    set backspace=2

    " Copy/paste from the clipboard. For Windows/Mac use: set clipboard=unnamed
    set clipboard+=unnamedplus

    " Don't set the GUI settings as I unly use terminal NeoVim
    set guioptions=M

     " Don't try to highlight lines longer than 800 characters.
    set synmaxcol=800

    " do not redraw while running macros (much faster) (LazyRedraw)
    set lazyredraw

    " Set 5 lines to the cursor - when moving vertically using j/k
    set scrolloff=5

    " Ignore these files in autocomplition, NERDTree and Denite
    set wildignore+=*.pyc,*.pyo,*.so,*.o,__pycache__,**/.git/**,.coverage,**/node_modules/**,.idea,*.png,*.jpeg,*.pdf,*.svg,**/__vcr_cassettes__/**,**/.pytest_cache/**,**/.mypy_cache/**

    set nobackup                     " disable backups
    set noswapfile                   " it's 2015, NeoVim.
" }}}
" Plugin settings {{{
    if (!isdirectory(expand("$HOME/.cache/dein/repos/github.com/Shougo/dein.vim")))
        call system(expand("mkdir -p $HOME/.cache/dein/repos/github.com"))
        call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.cache/dein/repos/github.com/Shougo/dein.vim"))
    endif

    set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

    if dein#load_state('~/.cache/dein')
        call dein#begin('~/.cache/dein')
        call dein#load_toml(expand('~/.config/nvim/plugins.toml'))
        call dein#end()
        call dein#save_state()
    endif
" }}}
" Mappings {{{
    " I'm mistyping this all the time...
    nnoremap q: :q
    nnoremap q; :q

    " Easily scroll up/down in insert mode
    inoremap <C-b> <C-x><C-y>
    inoremap <C-f> <C-x><C-e>

    " Because the Esc key is too far...
    inoremap jj <Esc>

    " Make the current word UPPERCASE and
    " move the cursor at the end of the word
    inoremap <c-u> <esc>viwUea
    nnoremap <c-u> viwUe

    " It's easier - you don't need to use shift... Furthermore, there are no
    " mistakes such as :W :)
    nnoremap ; :

    " Format current paragraph (Ex-mode sucks...)
    nnoremap <silent> Q gwip
    
    " Change keyboard layouts
    inoremap <C-z> <C-^>
    cnoremap <C-z> <C-^>

    " Select the whole line without the indentation. Useful for python code...
    nnoremap vv ^vg_

    " Paste in the next line.
    nnoremap <leader>p o<ESC>p

    " Insert semicolon at the end of the line and
    " return the cursor back to his previous place.
    inoremap <leader>; <C-o>m`<C-o>A;<C-o>``
    nnoremap <leader>; m`A;<Esc>``

    " Insert comma at the end of the line and
    " return the cursor back to his previous place.
    inoremap <leader>, <C-o>m`<C-o>A,<C-o>``
    nnoremap <leader>, m`A,<Esc>``

    " Sudo to write
    cnoremap w!! w !sudo tee % >/dev/null

    " Close the QuckFix
    nnoremap <leader>q :cclose<CR>

    " Switching between tabs
    nnoremap K :tabn<CR>
    nnoremap J :tabp<CR>

    " Reselect visual block after indent/dedent
    vnoremap < <gv
    vnoremap > >gv

    " Easily go to the beginning/end of the line
    noremap H ^
    noremap L $
    vnoremap L g_

    " Difftool mappings
    if &diff
        nnoremap <leader>dl :diffget LOCAL<CR>
        nnoremap <leader>db :diffget BASE<CR>
        nnoremap <leader>dr :diffget REMOTE<CR>
        nnoremap <leader>du :diffupdate<CR>
    endif

    " Increment/decrement numbers with +/-
    nnoremap + <C-a>
    nnoremap - <C-x>

    " Fix broken syntax highlighting
    nnoremap <F12> :syntax sync fromstart<CR>

    " Open the directory of the current file in the default file manager
    nnoremap <silent> <leader>od :silent !xdg-open "%:p:h"<CR>

    " ref: https://github.com/christoomey/vim-tmux-navigator/blob/master/plugin/tmux_navigator.vim
    function! MyTmuxAwareNavigate(direction) " {{{
        let nr = winnr()
        execute 'wincmd ' . a:direction

        if nr == winnr() && !empty($TMUX)
            let move_pane_dir_args = {
                \ "h": "-L M-h",
                \ "j": "-D M-j",
                \ "k": "-U M-k",
                \ "l": "-R M-l"
            \ }[a:direction]

            call system("~/scripts/move-pane.sh " . move_pane_dir_args . " --ignore_vim")
        endif
    endfunction " }}}

    nnoremap <silent> <M-h> :call MyTmuxAwareNavigate('h')<CR>
    nnoremap <silent> <M-j> :call MyTmuxAwareNavigate('j')<CR>
    nnoremap <silent> <M-k> :call MyTmuxAwareNavigate('k')<CR>
    nnoremap <silent> <M-l> :call MyTmuxAwareNavigate('l')<CR>

    nnoremap <silent> <F1> :set number!<CR>
" }}}
" Interface {{{
    " Colors {{{
        syntax on

        " Disable syntax for very large files
        augroup large_files
            au!
            au BufWinEnter * if line2byte(line("$") + 1) > 1000000 | syntax clear | endif
        augroup END

        if (has("nvim"))
            let $NVIM_TUI_ENABLE_TRUE_COLOR=1
        endif

        if (has("termguicolors"))
            set termguicolors
        endif

        set background=dark
        
        " http://terminal.sexy/ is an awesome website to find out (and create) more :)
        " Other cool dark 256 color colorschemes:
        " colorscheme neverland

        " let g:seoul256_background = 233
        " colo seoul256

        " colorscheme mango
        " colorscheme xoria256
        " colorscheme solarized
        "
        " colorscheme hybrid
        " highlight ALEErrorSign ctermfg=red ctermbg=234
        " highlight ALEWarningSign ctermfg=yellow ctermbg=234

        " Gruvbox Theme Settings {{{
            " Enables bold text.
            " Default: 1
            let g:gruvbox_bold = '1'

            " Enables italic text.
            " Default: gui 1, term 0
            let g:gruvbox_italic = '1'

            " Enables transparent background.
            " Default: 0
            let g:gruvbox_transparent_bg = '0'

            " Enables underlined text.
            " Default: 1
            let g:gruvbox_underline = '1'

            " Enables undercurled text.
            " Default: 1
            let g:gruvbox_undercurl = '1'

            " Uses 256-color palette (suitable to pair with gruvbox-palette shell script).
            " If you're dissatisfied with that, set option value to 16 to fallback base colors to your terminal palette. Refer † for details.
            " Default: 256
            let g:gruvbox_termcolors = '256'

            " Changes dark mode contrast. Overrides g:gruvbox_contrast option. Possible values are soft, medium and hard.
            " Default: medium
            let g:gruvbox_contrast_dark = 'hard'

            " Changes light mode contrast. Overrides g:gruvbox_contrast option. Possible values are soft, medium and hard.
            " Default: medium
            let g:gruvbox_contrast_light = 'hard'

            " Changes cursor background while search is highlighted. Possible values are any of gruvbox palette.
            " Default: orange
            let g:gruvbox_hls_cursor = 'orange'

            " Changes number column background color. Possible values are any of gruvbox palette.
            " Default: none
            let g:gruvbox_number_column = 'bg0'

            " Changes sign column background color. Possible values are any of gruvbox palette.
            " Default: bg1
            let g:gruvbox_sign_column = 'bg0'

            " Changes color column background color. Possible values are any of gruvbox palette.
            " Default: bg1
            let g:gruvbox_color_column = 'dark0'

            " Changes vertical split background color. Possible values are any of gruvbox palette.
            " Default: bg0
            let g:gruvbox_vert_split = 'bg0'

            " Enables italic for comments.
            " Default: 1
            let g:gruvbox_italicize_comments = '0'

            " Enables italic for strings.
            " Default: 0
            let g:gruvbox_italicize_strings = '0'

            " Inverts selected text.
            " Default: 1
            let g:gruvbox_invert_selection = '0'

            " Inverts GitGutter and Syntastic signs. Useful to rapidly focus on.
            " Default: 0
            let g:gruvbox_invert_signs = '0'

            " Inverts indent guides. Could be nice paired with set list so it would highlight only tab symbols instead of it's background.
            " Default: 0
            let g:gruvbox_invert_indent_guides = '0'

            " Inverts tabline highlights, providing distinguishable tabline-fill.
            " Default: 0
            let g:gruvbox_invert_tabline = '0'

            " Extrahighlighted strings
            " Default: 0
            let g:gruvbox_improved_strings = '0'

            " Extrahighlighted warnings
            " Default: 0
            let g:gruvbox_improved_warnings = '0'

            " Delegates guisp colorings to guifg or guibg. This is handy for terminal vim.
            " Uses guifg or guibg for colors originally assigned to guisp.
            " guisp concerns the colors of underlines and strikethroughs.
            " Terminal vim cannot color underlines and strikethroughs, only gVim can.
            " This option instructs vim to color guifg or guibg as a fallback.
            "
            " Default: 'NONE'
            " Possible Values: 'fg', 'bg'
            let g:gruvbox_guisp_fallback = 'fg'
        " }}}

	    colorscheme gruvbox

        highlight! CursorLine guibg=#282828 ctermbg=235
        highlight! Visual guibg=#504945 ctermbg=239
        highlight! link Folded CursorLine
        highlight! link FoldColumn CursorLine

        " highlight! Folded guibg=#32302f ctermbg=236
        " highlight! FoldColumn guibg=#32302f ctermbg=236

        highlight! link ALEErrorSign GruvboxRed
        highlight! link ALEWarningSign GruvboxYellow

        highlight! link logLevelInfo GruvboxGreenBold
        highlight! link logLevelWarning GruvboxYellowBold
        highlight! link logLevelError GruvboxRedBold

        highlight link Flashy Visual
    " }}}
    " Folding {{{
        fu! CustomFoldText() " {{{
            "get first non-blank line
            let fs = v:foldstart
            while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
            endwhile
            if fs > v:foldend
                let line = getline(v:foldstart)
            else
                let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
            endif

            let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
            let foldSize = 1 + v:foldend - v:foldstart
            let foldSizeStr = " " . foldSize . " lines "
            let foldLevelStr = repeat("+", v:foldlevel)
            let lineCount = line("$")
            let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
            let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
            return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
        endf "}}}

        set foldtext=CustomFoldText()
        set foldmethod=indent
        set foldignore=
        set foldnestmax=2

        let javaScript_fold=1

        " It's easier to use space...
        nnoremap <space> za

        " Focus the current folding
        nnoremap <leader>z zMzvzz
    " }}}

    set nonumber
    set cursorline
    set colorcolumn=100
    set textwidth=100

    " Enable spellcheck
    let g:spelllang = 'en_gb'
    set spell

    " Only show cursorline in the current buffer and in normal mode.
    augroup cline
        au!
        au WinLeave,InsertEnter * set nocursorline
        au WinEnter,InsertLeave * set cursorline
    augroup END

    set ruler
    set mouse=a
" }}}
" Tabs and spaces {{{
    " TODO: Research more all the options and document them here
    " Create two modes (via functions?):
    "     * 4 spaces indentation (default)
    "     * Tabs indentation (width = 4)
    " Set exceptions for some file types / projects (localvimrc)
    " https://vim.fandom.com/wiki/Indent_with_tabs,_align_with_spaces

    set smartindent
    set expandtab     " insert spaces when hitting TABs
    set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
    set tabstop=4     " an hard TAB displays as 4 columns
    set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
    set shiftround    " round indent to multiple of 'shiftwidth'
" }}}
" Searching {{{
    set ignorecase
    set smartcase

    " Highlight search results
    set hlsearch

    " Makes search act like search in modern browsers
    set incsearch

    " Visual :%s substitution
    set inccommand=nosplit

    " Clear search highlights
    noremap <silent><Leader>/ :nohls<CR>

    " Don't jump to the next match when * is pressed
    nnoremap * *``

    " Centers the screen on searching
    nnoremap n nzzzv
    nnoremap N Nzzzv
" }}}
" Quick editing {{{
    " TODO: Replace this with telescope + yadm
    let quick_edit_prefix = '<leader>e'
    let quick_edit_files = {
        \ 'vr': "$MYVIMRC",
        \ 'vp': "~/.config/nvim/plugins.toml",
        \ 'b': "~/.bashrc",
        \ 'zr': "~/.zshrc",
        \ 'zl': "~/.zshrc_local",
        \ 'zp': "~/.zprofile",
        \ 'za': "~/.aliases",
        \ 'tr': "~/.tmux.conf",
        \ 'xr': "~/.Xresources",
        \ 'xl': "~/.Xresources_local",
        \ }
    
    for [mapping, file_path] in items(quick_edit_files)
        execute 'nnoremap ' . quick_edit_prefix . mapping . ' :tabedit ' . file_path . '<CR>'
    endfor

    function! TabEditLvimrc() " {{{
        let l:file = fnameescape(b:localvimrc_sourced_files[0])
        execute 'tabedit ' . l:file
    endfunction " }}}

    execute 'nnoremap ' . quick_edit_prefix . 'vl' . ' :call TabEditLvimrc()<CR>'
" }}}
" Splits {{{
    " Resize splits when the window is resized
    au VimResized * exe "normal! \<c-w>="

    set splitbelow
    set splitright

    " Resizing splits
    nnoremap <left>  <c-w><
    nnoremap <right> <c-w>>
    nnoremap <up>    <c-w>-
    nnoremap <down>  <c-w>+
" }}}
" Filetype specific settings {{{
    augroup ft_viml
        au!
        au FileType vim setlocal foldmethod=marker
    augroup END
    augroup ft_tmux
        au!
        au FileType tmux setlocal foldmethod=marker
    augroup END
    augroup ft_python
        au!
        au FileType python setlocal foldnestmax=2
    augroup END
" }}}
" Utils {{{
    set t_ut=
" }}}
filetype plugin indent on
