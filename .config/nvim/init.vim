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
	set wildignore+=*.pyc,*.pyo,*.so,*.o,__pycache__

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
		" TODO: Extract that into a variable
		call dein#load_toml(expand('~/.config/nvim/plugins.toml'))
		call dein#end()
		call dein#save_state()
	endif
	" ale {{{
		let g:ale_sign_column_always = 1
		let g:ale_sign_error = '✗'
		let g:ale_sign_warning = ''

		nmap <A-k> <Plug>(ale_previous_wrap)
		nmap <A-j> <Plug>(ale_next_wrap)

		let g:ale_python_flake8_args = '--max-line-length=120 --ignore=F403'
	" }}}
	" emmet {{{
		" TODO: Use SuperTab. `` is actually quite useful
		let g:user_emmet_install_global = 0
		autocmd FileType html,css EmmetInstall
		let g:user_emmet_expandabbr_key = '``'
		let g:user_emmet_next_key = '`j'
		let g:user_emmet_prev_key = '`k'
		let g:use_emmet_complete_tag = 1
	" }}}
	" vim-surround {{{
		autocmd FileType htmldjango let b:surround_{char2nr("v")} = "{{ \r }}"
		autocmd FileType htmldjango let b:surround_{char2nr("t")} = "{% \r %}"

		" Bold, italic and underline in TeX/LaTeX
		autocmd FileType tex let b:surround_{char2nr("b")} = "\\textbf{\r}"
		autocmd FileType tex let b:surround_{char2nr("i")} = "\\textit{\r}"
		autocmd FileType tex let b:surround_{char2nr("u")} = "\\underline{\r}"

		" Bold and italic in markdown
		autocmd FileType mkd let b:surround_{char2nr("b")} = "**\r**"
		autocmd FileType mkd let b:surround_{char2nr("i")} = "_\r_"

		" Bold and italic in rst
		autocmd FileType rst let b:surround_{char2nr("b")} = "**\r**"
		autocmd FileType rst let b:surround_{char2nr("i")} = "*\r*"
	" }}}
	" limelight.vim {{{
		let g:limelight_conceal_ctermfg = 'black'
	" }}}
	" goyo.vim {{{
		let g:goyo_margin_top=0
		let g:goyo_margin_bottom=0
		let g:goyo_linenr=2

		function! GoyoBefore()
			silent !tmux set status off
			normal zR
			set nonumber
			" Limelight
		endfunction

		function! GoyoAfter()
			silent !tmux set status on
			set number
			" Limelight!
		endfunction

		let g:goyo_callbacks = [function('GoyoBefore'), function('GoyoAfter')]
	" }}}
	" InstantRst {{{
		let g:instant_rst_browser = "google-chrome-stable"
	" }}}
	" python-mode {{{
		" Disable nearly all the functions of python-mode since I use other
		" plugins for them. Ones far younger and more powerful!

		call pymode#default('g:pymode_doc', 0)
		call pymode#default("g:pymode_indent", 0)
		call pymode#default("g:pymode_motion", 0)
		call pymode#default("g:pymode_options", 0)
		call pymode#default('g:pymode_virtualenv', 0)
		call pymode#default('g:pymode_run', 0)
		call pymode#default('g:pymode_lint', 0)
		call pymode#default('g:pymode_rope', 0)

		call pymode#default("g:pymode_folding", 0)
		" call pymode#default("g:pymode_folding", 1)
		" call pymode#default("g:pymode_folding_nest_limit", 1000)
		" call pymode#default("g:pymode_folding_regex", '^\s*\%(class\|def\|async\s\+def\) .\+\(:\s\+\w\)\@!')

		" I'm using it only for the breakpoints. For now.

		call pymode#default('g:pymode_breakpoint', 1)
		call pymode#default('g:pymode_breakpoint_bind', '<C-b>')
		call pymode#default('g:pymode_breakpoint_cmd', 'import ptpdb; ptpdb.set_trace()')

		call pymode#default("g:pymode_trim_whitespaces", 1)
	" }}}
	" vim-exchange {{{
		nmap X <Plug>(Exchange)
		xmap X <Plug>(Exchange)
		nmap cX <Plug>(ExchangeClear)
		nmap XX <Plug>(ExchangeLine)
	" }}}
	" vim-multiple-cursors {{{
		let g:multi_cursor_insert_maps = { 'j': 1 }

		function! Multiple_cursors_before()
			let b:deoplete_disable_auto_complete = 1
		endfunction

		function! Multiple_cursors_after()
			let b:deoplete_disable_auto_complete = 0
		endfunction
	" }}}
	" vim-slime {{{
		let g:slime_target = "tmux"	

		let g:slime_no_mappings = 1
		xmap <C-c> <Plug>SlimeRegionSend
		nmap <C-c> <Plug>SlimeLineSend
	" }}}
	" vim-projectionist {{{
		" Jump to the alternate file
		nnoremap <leader>a :A<CR>
	" }}}
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

	" Select the whole line without the identation. Useful for python code...
	" TODO: Don't enable this in NERD Tree
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

	" Toggle spellcheck
	let g:myLang = 0
	let g:myLangList = ['nospell', 'en_gb', 'bg']
	function! MySpellLang() " {{{
		if g:myLang == 0 | setlocal nospell | endif
		if g:myLang == 1 | let &l:spelllang = g:myLangList[g:myLang] | setlocal spell | endif
		if g:myLang == 2 | let &l:spelllang = g:myLangList[g:myLang] | setlocal spell | endif
		echomsg 'Language:' g:myLangList[g:myLang]
		let g:myLang = g:myLang + 1
		if g:myLang >= len(g:myLangList) | let g:myLang = 0 | endif
	endfunction " }}}
	nnoremap <leader>s :<C-U>call MySpellLang()<CR>

	" Sudo to write
	cnoremap w!! w !sudo tee % >/dev/null

	" Close the QuckFix
	nnoremap <leader>q :cclose<CR>

	" Switching between tabs
	nnoremap K :tabn<CR>
	nnoremap J :tabp<CR>

	" Reselect visual block after indent/outdent
	vnoremap < <gv
	vnoremap > >gv

	" Eazily go to the beginning/end of the line
	noremap H ^
	noremap L $
	vnoremap L g_

	" TODO: Should these be global?
	" Difftool mappings
	nnoremap <leader>dl :diffget LOCAL<CR>
	nnoremap <leader>db :diffget BASE<CR>
	nnoremap <leader>dr :diffget REMOTE<CR>
	nnoremap <leader>du :diffupdate<CR>
" }}}
" Interface {{{
    " Colors {{{
		syntax on
		
		" http://terminal.sexy/ is an awesome website to find out (and create) more :)
		" Other cool dark 256 color colorschemes:
		" colorscheme neverland

		" let g:seoul256_background = 233
		" colo seoul256

		" colorscheme mango
		" colorscheme xoria256
		" colorscheme solarized
		set background=dark
		colorscheme hybrid

		highlight ALEErrorSign ctermfg=red ctermbg=234
		highlight ALEWarningSign ctermfg=yellow ctermbg=234

		highlight Flashy ctermbg=239
	" }}}
	set number
	augroup numbertoggle
		autocmd!
		autocmd BufEnter,FocusGained * setlocal number
		autocmd BufLeave,FocusLost * setlocal nonumber
	augroup END

	set ruler
	set cursorline
	set mouse=a
" }}}
" Tabs and spaces {{{
    set smartindent
    set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
    set tabstop=4     " an hard TAB displays as 4 columns
    set shiftround    " round indent to multiple of 'shiftwidth'
" }}}
" Searching {{{
	set ignorecase
	set smartcase

	" Highlight search results
	set hlsearch

	" Makes search act like search in modern browsers
	set incsearch

	" Clear search highlights
	noremap <silent><Leader>/ :nohls<CR>

	" Don't jump to the next match when * is pressed
	nnoremap * *``

	" Centers the screen on searching
	nnoremap n nzzzv
	nnoremap N Nzzzv
" }}}
" Folding {{{
	set foldlevelstart=0
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

	let javaScript_fold=1

	" It's easier to use space...
	nnoremap <space> za

	" Focus the current folding
	nnoremap <leader>z zMzvzz
" }}}
" Quick editing {{{
	" TODO: Try to simulate denite's tabswitch
	let tmux_theme_name = system('grep "TMUX_POWERLINE_THEME" ~/.tmux-powerlinerc | sed -r "s/^.*?([\"''])(.*?)\1\s*$/\2/"')
    let tmux_theme_name = substitute(tmux_theme_name, '\n$', '', '')

	let zsh_theme_name = system('grep "ZSH_THEME" ~/.zshrc | sed -r "s/^.*?([\"''])(.*?)\1\s*$/\2/"')
    let zsh_theme_name = substitute(zsh_theme_name, '\n$', '', '')

	let quick_edit_prefix = '<leader>e'
	let quick_edit_files = {
		\ 'vr': "$MYVIMRC",
		\ 'vp': "~/.config/nvim/plugins.toml",
		\ 'b': "~/.bashrc",
		\ 'zr': "~/.zshrc",
		\ 'zl': "~/.zshrc_local",
		\ 'zp': "~/.zprofile",
		\ 'za': "~/.aliases",
		\ 'zt': "~/.oh-my-zsh/custom/themes/" . zsh_theme_name . ".zsh-theme",
		\ 'tr': "~/.tmux.conf",
		\ 'tc': "~/.tmux-powerlinerc",
		\ 'tt': "~/.tmux/tmux-powerline/themes/" . tmux_theme_name . ".sh",
		\ }
	
	for [mapping, file_path] in items(quick_edit_files)
		execute 'nnoremap ' . quick_edit_prefix . mapping . ' :tabedit ' . file_path . '<CR>'
	endfor
" }}}
" Splits {{{
	" Resize splits when the window is resized
	au VimResized * exe "normal! \<c-w>="

	set splitbelow
	set splitright

	" Only show cursorline in the current buffer and in normal mode.
	augroup cline "{{{
		au!
		au WinLeave,InsertEnter * set nocursorline
		au WinEnter,InsertLeave * set cursorline
	augroup END "}}}

	" Only show line numbers numbers and the ALE gutter in the current buffer.
	" augroup linenum "{{{
	" 	au!
	" 	au WinLeave * setlocal nonumber | :sign unplace *
	" 	au WinEnter * setlocal number | :ALELint
	" augroup END "}}}

	" Resizing splits {{{
		nnoremap <left>  <c-w><
		nnoremap <right> <c-w>>
		nnoremap <up>    <c-w>-
		nnoremap <down>  <c-w>+
	" }}}
	" Splits navigation {{{
		nnoremap gh <C-w>h
		nnoremap gj <C-w>j
		nnoremap gk <C-w>k
		nnoremap gl <C-w>l
	" }}}
" }}}
" Filetype specific settings {{{
	" Automaticlly set filetypes {{{
		augroup auto_ft
			au!
			au BufRead, BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif
		augroup END
		let g:tex_flavor = "latex"
	" }}}
	" C {{{
		augroup ft_c
			au!
			au FileType c setlocal foldmethod=syntax
		augroup END
	"}}}
	" C++ {{{
		augroup ft_cpp
			au!
			au FileType cpp setlocal foldmethod=syntax
		augroup END
	"}}}
	" CoffeeScript {{{
		augroup ft_coffee
			au!
			au FileType coffee setlocal foldmethod=indent
			au FileType coffee setlocal shiftwidth=2
			au FileType coffee setlocal tabstop=2
			au FileType coffee setlocal expandtab
			au FileType coffee setlocal softtabstop=2
			au FileType coffee setlocal shiftround
		augroup END
	" }}}
	" Django {{{
		augroup ft_django
			au!
			au BufNewFile,BufRead urls.py           setlocal nowrap
			au BufNewFile,BufRead urls.py           normal! zR
			au BufNewFile,BufRead dashboard.py      normal! zR
			au BufNewFile,BufRead local_settings.py normal! zR

			au BufNewFile,BufRead admin.py     setlocal filetype=python.django
			au BufNewFile,BufRead urls.py      setlocal filetype=python.django
			au BufNewFile,BufRead models.py    setlocal filetype=python.django
			au BufNewFile,BufRead views.py     setlocal filetype=python.django
			au BufNewFile,BufRead settings.py  setlocal filetype=python.django
			au BufNewFile,BufRead settings.py  setlocal foldmethod=marker
			au BufNewFile,BufRead forms.py     setlocal filetype=python.django
			au BufNewFile,BufRead common_settings.py  setlocal filetype=python.django
			au BufNewFile,BufRead common_settings.py  setlocal foldmethod=marker
		augroup END
	" }}}
	" Vimscript {{{
		augroup ft_viml
			au!
			au FileType vim setlocal foldmethod=marker
		augroup END
	" }}}
	" Tmux {{{
		augroup ft_tmux
			au!
			au FileType tmux setlocal foldmethod=marker
		augroup END
	" }}}
	" Python {{{
		augroup ft_python
			au!
			au FileType python setlocal shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
			au FileType python setlocal tabstop=4     " an hard TAB displays as 4 columns
			au FileType python setlocal expandtab     " insert spaces when hitting TABs
			au FileType python setlocal softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
			au FileType python setlocal shiftround    " round indent to multiple of 'shiftwidth'
			au FileType python setlocal autoindent    " align the new line indent with the previous line
			au FileType python setlocal colorcolumn=121
		augroup END
	" }}}
	" TOML {{{
		augroup ft_toml
			au!
			au FileType toml setlocal shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
			au FileType toml setlocal tabstop=4     " an hard TAB displays as 4 columns
			au FileType toml setlocal expandtab     " insert spaces when hitting TABs
			au FileType toml setlocal softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
			au FileType toml setlocal foldmethod=marker
		augroup END
	" }}}
	" CTP {{{
		augroup ft_ctp
			au!
			au FileType ctp setlocal shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
			au FileType ctp setlocal tabstop=4     " an hard TAB displays as 4 columns
			au FileType ctp setlocal expandtab     " insert spaces when hitting TABs
			au FileType ctp setlocal softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
			au FileType ctp setlocal shiftround    " round indent to multiple of 'shiftwidth'
			au FileType ctp setlocal autoindent    " align the new line indent with the previous line
		augroup END
	" }}}
	" JavaScript {{{
		augroup ft_js
			au!
			au FileType javascript setlocal foldmethod=syntax
			au FileType javascript setlocal shiftwidth=4
			au FileType javascript setlocal tabstop=4
			au FileType javascript setlocal expandtab
			au FileType javascript setlocal softtabstop=4
			au FileType javascript setlocal shiftround
		augroup END
	" }}}
	" Clojure {{{
		augroup ft_clojure
			au!
			au FileType clojure setlocal foldmethod=syntax
		augroup END
	" }}}
	" HTML {{{
		augroup ft_html
			au!
			au FileType htmldjango.html setlocal shiftwidth=2
			au FileType htmldjango.html setlocal tabstop=2
			au FileType htmldjango.html setlocal expandtab
			au FileType htmldjango.html setlocal softtabstop=2
			au FileType htmldjango.html setlocal shiftround
		augroup END
	" }}}
	" Jade {{{
		augroup ft_jade
			au!
			au FileType jade setlocal nofoldenable
			au FileType jade setlocal shiftwidth=2
			au FileType jade setlocal tabstop=2
			au FileType jade setlocal expandtab
			au FileType jade setlocal softtabstop=2
			au FileType jade setlocal shiftround
		augroup END
	" }}}
	" Markdown {{{
		augroup ft_mkd
			au!
			au FileType mkd setlocal textwidth=80
			au FileType mkd nnoremap <buffer> <leader><space> :Goyo<CR>
		augroup END
	" }}}
	" reStructuredText {{{
		augroup ft_rst
			au!
			au FileType rst setlocal textwidth=79
			au FileType rst setlocal colorcolumn=80
			au FileType rst nnoremap <buffer> <leader><space> :Goyo<CR>
		augroup END
	" }}}
	" LaTeX {{{
		augroup ft_tex
			au!
			au FileType tex setlocal textwidth=80
			au FileType tex setlocal foldmethod=manual
		augroup END
	" }}}
	" CSS {{{
		augroup ft_css
			au!
			au FileType css setlocal foldmethod=syntax
		augroup END
	" }}}
	" SCSS {{{
		augroup ft_scss
			au!
			au FileType scss setlocal foldmethod=marker
			au FileType scss setlocal foldmarker={,}
			au FileType scss setlocal shiftwidth=2
			au FileType scss setlocal tabstop=2
			au FileType scss setlocal expandtab
			au FileType scss setlocal softtabstop=2
			au FileType scss setlocal shiftround
		augroup END
	" }}}
	" Sass {{{
		augroup ft_sass
			au!
			au FileType sass setlocal foldmethod=indent
			au FileType sass setlocal shiftwidth=2
			au FileType sass setlocal tabstop=2
			au FileType sass setlocal expandtab
			au FileType sass setlocal softtabstop=2
			au FileType sass setlocal shiftround
		augroup END
	" }}}
	" Lua {{{
		augroup ft_lua
			au!
			au FileType lua setlocal foldmethod=marker
			au FileType lua setlocal shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
			au FileType lua setlocal tabstop=4     " an hard TAB displays as 4 columns
			au FileType lua setlocal expandtab     " insert spaces when hitting TABs
			au FileType lua setlocal softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
			au FileType lua setlocal shiftround    " round indent to multiple of 'shiftwidth'
			au FileType lua setlocal autoindent    " align the new line indent with the previous line
		augroup END
	" }}}
	" Nonvim {{{
		augroup nonvim
			au!
			au BufRead *.png,*.jpg,*.pdf,*.gif,*.scpt sil exe "!xdg-open " . shellescape(expand("%:p")) | bd | let &ft=&ft | redraw!
		augroup END
	" }}}
" }}}
" Utils {{{
	set t_ut=
" }}}
filetype plugin indent on
