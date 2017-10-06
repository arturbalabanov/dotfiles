" ~/dotfiles/vim/sessions/edumax.vim:
" Vim session script.
" Created by session.vim 2.4.9 on 22 February 2014 at 18:12:06.
" Open this file in Vim and run :source % to restore your session.

set guioptions=aegimrLtT
silent! set guifont=
if exists('g:syntax_on') != 1 | syntax on | endif
if exists('g:did_load_filetypes') != 1 | filetype on | endif
if exists('g:did_load_ftplugin') != 1 | filetype plugin on | endif
if exists('g:did_indent_on') != 1 | filetype indent on | endif
if &background != 'light'
	set background=light
endif
if !exists('g:colors_name') || g:colors_name != 'xoria256' | colorscheme xoria256 | endif
call setqflist([])
let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/projects/edumax
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 accounts/models.py
badd +14 accounts/admin.py
badd +1 accounts/views.py
badd +29 ~/projects/twitter/users/admin.py
badd +178 edumax/settings/base.py
badd +1 ~/.vimrc
badd +4 edumax/templates/index.html
badd +159 assets/index.html
badd +41 edumax/templates/base.html
badd +11 accounts/urls.py
badd +13 edumax/urls.py
badd +93 accounts/forms.py
badd +6 accounts/templates/login_page.html
badd +8 accounts/templates/register_page.html
badd +200 /usr/local/lib/python2.7/dist-packages/django/contrib/auth/models.py
badd +1 ~/projects/twitter/users/views.py
badd +36 ~/projects/twitter/twitter/views.py
badd +49 ~/projects/twitter/templates/index.html
badd +13 ~/projects/twitter/twitter/urls.py
badd +176 /usr/local/lib/python2.7/dist-packages/django/contrib/auth/forms.py
badd +1 accounts/ajax.py
badd +4 accounts/static/coffee/register_page_scripts.coffee
badd +1 accounts/tests/test_forms.py
badd +1 courses/models.py
badd +14 courses/urls.py
badd +11 courses/views.py
badd +16 courses/templates/course_list_page.html
badd +20 courses/templates/course_detail_page.html
badd +26 accounts/templates/user_detail_page.html
badd +1 forum/urls.py
badd +14 forum/models.py
badd +8 forum/views.py
badd +11 forum/templates/forum_post_list_page.html
badd +0 forum/ajax.py
silent! argdel *
edit accounts/models.py
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
2wincmd k
wincmd w
wincmd w
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 28 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 8 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
exe '4resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 84 + 84) / 169)
exe '5resize ' . ((&lines * 15 + 20) / 40)
exe 'vert 5resize ' . ((&columns * 84 + 84) / 169)
" argglobal
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
5
silent! normal! zo
let s:l = 14 - ((13 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
14
normal! 0
wincmd w
" argglobal
edit accounts/admin.py
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
6
silent! normal! zo
7
silent! normal! zo
6
normal! zc
let s:l = 1 - ((0 * winheight(0) + 4) / 8)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 032|
wincmd w
" argglobal
edit accounts/urls.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 16 - ((9 * winheight(0) + 5) / 10)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
16
normal! 0
wincmd w
" argglobal
edit accounts/views.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
82
silent! normal! zo
let s:l = 84 - ((57 * winheight(0) + 5) / 10)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
84
normal! 05|
wincmd w
" argglobal
edit accounts/ajax.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
8
silent! normal! zo
let s:l = 1 - ((0 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
exe '1resize ' . ((&lines * 28 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 8 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
exe '4resize ' . ((&lines * 10 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 84 + 84) / 169)
exe '5resize ' . ((&lines * 15 + 20) / 40)
exe 'vert 5resize ' . ((&columns * 84 + 84) / 169)
tabedit courses/models.py
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winheight=1 winwidth=1
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 6 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 30 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
" argglobal
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
7
silent! normal! zo
7
normal! zc
17
silent! normal! zo
let s:l = 2 - ((1 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
2
normal! 0
wincmd w
" argglobal
edit courses/urls.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 14 - ((2 * winheight(0) + 3) / 6)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
14
normal! 05|
wincmd w
" argglobal
edit courses/views.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
11
silent! normal! zo
36
silent! normal! zo
36
normal! zc
let s:l = 11 - ((10 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
11
normal! 0
wincmd w
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 6 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 30 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
tabedit forum/models.py
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 15 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
exe '4resize ' . ((&lines * 21 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 84 + 84) / 169)
" argglobal
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
13
silent! normal! zo
let s:l = 14 - ((10 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
14
normal! 0
wincmd w
" argglobal
edit forum/ajax.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
9
silent! normal! zo
let s:l = 6 - ((5 * winheight(0) + 9) / 18)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
6
normal! 0
wincmd w
" argglobal
edit forum/urls.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 15 - ((12 * winheight(0) + 7) / 15)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
15
normal! 0
wincmd w
" argglobal
edit forum/views.py
setlocal fdm=expr
setlocal fde=pymode#folding#expr(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
6
silent! normal! zo
let s:l = 7 - ((6 * winheight(0) + 10) / 21)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
7
normal! 05|
wincmd w
2wincmd w
exe '1resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 1resize ' . ((&columns * 84 + 84) / 169)
exe '2resize ' . ((&lines * 18 + 20) / 40)
exe 'vert 2resize ' . ((&columns * 84 + 84) / 169)
exe '3resize ' . ((&lines * 15 + 20) / 40)
exe 'vert 3resize ' . ((&columns * 84 + 84) / 169)
exe '4resize ' . ((&lines * 21 + 20) / 40)
exe 'vert 4resize ' . ((&columns * 84 + 84) / 169)
tabedit forum/templates/forum_post_list_page.html
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
6
silent! normal! zo
7
silent! normal! zo
8
silent! normal! zo
9
silent! normal! zo
10
silent! normal! zo
11
silent! normal! zo
17
silent! normal! zo
19
silent! normal! zo
17
silent! normal! zo
19
silent! normal! zo
17
normal! zc
let s:l = 11 - ((10 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
11
normal! 044|
2wincmd w
tabedit courses/templates/course_list_page.html
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
8
silent! normal! zo
9
silent! normal! zo
10
silent! normal! zo
11
silent! normal! zo
12
silent! normal! zo
19
silent! normal! zo
let s:l = 16 - ((15 * winheight(0) + 18) / 37)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
16
normal! 059|
2wincmd w
tabnext 3
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

tabnext 3
2wincmd w
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
