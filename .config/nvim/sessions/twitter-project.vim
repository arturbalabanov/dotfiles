" ~/dotfiles/vim/sessions/twitter-project.vim:
" Vim session script.
" Created by session.vim 2.4.9 on 12 November 2013 at 00:34:03.
" Open this file in Vim and run :source % to restore your session.

set guioptions=aegimrLtT
silent! set guifont=
if exists('g:syntax_on') != 1 | syntax on | endif
if exists('g:did_load_filetypes') != 1 | filetype on | endif
if exists('g:did_load_ftplugin') != 1 | filetype plugin on | endif
if exists('g:did_indent_on') != 1 | filetype indent on | endif
if &background != 'dark'
	set background=dark
endif
call setqflist([])
let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/projects/twitter
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +29 twitter/views.py
badd +9 templates/index.html
badd +1 static/users/coffee/index-scripts.coffee
badd +1 static/users/sass/screen.scss
badd +10 static/users/sass/index-styles.sass
badd +3 templates/invalid-login.html
badd +7 templates/logged-in.html
badd +12 users/models.py
badd +2 users/admin.py
badd +16 twitter/urls.py
badd +0 templates/user-profile.html
" args projects/twitter
edit templates/index.html
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 14 + 18) / 37)
exe '2resize ' . ((&lines * 19 + 18) / 37)
exe 'vert 2resize ' . ((&columns * 61 + 75) / 151)
exe '3resize ' . ((&lines * 19 + 18) / 37)
exe 'vert 3resize ' . ((&columns * 89 + 75) / 151)
" argglobal
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
11
silent! normal! zo
12
silent! normal! zo
13
silent! normal! zo
13
normal! zc
31
silent! normal! zo
32
silent! normal! zo
33
silent! normal! zo
35
silent! normal! zo
36
silent! normal! zo
40
silent! normal! zo
53
silent! normal! zo
let s:l = 9 - ((8 * winheight(0) + 7) / 14)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
9
normal! 0
wincmd w
" argglobal
edit static/users/coffee/index-scripts.coffee
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
2
silent! normal! zo
2
silent! normal! zo
let s:l = 2 - ((1 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 013|
wincmd w
" argglobal
edit static/users/sass/index-styles.sass
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
11
silent! normal! zo
13
silent! normal! zo
let s:l = 10 - ((9 * winheight(0) + 9) / 19)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
10
normal! 06|
wincmd w
exe '1resize ' . ((&lines * 14 + 18) / 37)
exe '2resize ' . ((&lines * 19 + 18) / 37)
exe 'vert 2resize ' . ((&columns * 61 + 75) / 151)
exe '3resize ' . ((&lines * 19 + 18) / 37)
exe 'vert 3resize ' . ((&columns * 89 + 75) / 151)
tabedit twitter/views.py
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 22 + 18) / 37)
exe '2resize ' . ((&lines * 11 + 18) / 37)
" argglobal
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
27
silent! normal! zo
36
silent! normal! zo
40
silent! normal! zo
41
silent! normal! zo
let s:l = 45 - ((37 * winheight(0) + 11) / 22)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
45
normal! 058|
wincmd w
" argglobal
edit twitter/urls.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 16 - ((5 * winheight(0) + 5) / 11)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
16
normal! 043|
wincmd w
exe '1resize ' . ((&lines * 22 + 18) / 37)
exe '2resize ' . ((&lines * 11 + 18) / 37)
tabedit templates/user-profile.html
set splitbelow splitright
wincmd t
set winheight=1 winwidth=1
" argglobal
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
4
silent! normal! zo
let s:l = 4 - ((3 * winheight(0) + 17) / 34)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
4
normal! 039|
tabedit templates/logged-in.html
set splitbelow splitright
wincmd t
set winheight=1 winwidth=1
" argglobal
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
4
silent! normal! zo
6
silent! normal! zo
7
silent! normal! zo
let s:l = 1 - ((0 * winheight(0) + 17) / 34)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 04|
tabnext 2
if exists('s:wipebuf')
"   silent exe 'bwipe ' . s:wipebuf
endif
" unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save

" Support for special windows like quick-fix and plug-in windows.
" Everything down here is generated by vim-session (not supported
" by :mksession out of the box).

tabnext 2
1wincmd w
if exists('s:wipebuf')
  if empty(bufname(s:wipebuf))
if !getbufvar(s:wipebuf, '&modified')
  let s:wipebuflines = getbufline(s:wipebuf, 1, '$')
  if len(s:wipebuflines) <= 1 && empty(get(s:wipebuflines, 0, ''))
    silent execute 'bwipeout' s:wipebuf
  endif
endif
  endif
endif
doautoall SessionLoadPost
unlet SessionLoad
" vim: ft=vim ro nowrap smc=128
