nnoremap <F8> :!pdflatex --output-directory="%:p:h" "%:p"<CR>
inoremap <F8> <Esc>:!pdflatex --output-directory="%:p:h" "%:p"<CR>

nnoremap <F9> :w<CR>:!pdflatex --output-directory="%:p:h" "%:p"<CR>
inoremap <F9> <Esc>:w<CR>:!pdflatex --output-directory="%:p:h" "%:p"<CR>

