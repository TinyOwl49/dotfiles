inoremap <C-s> <ESC>:w<CR>
nnoremap <C-s> <ESC>:w<CR>
tnoremap <Esc> <C-\><C-n>
noremap mp "0p

" filetype on

" augroup keymapcmd
"     " Remove all autocommands in this group
"     autocmd!
"     au BufRead,BufNewFile *.nim set filetype=nim
"     " <F5> key execution
"     au FileType python nnoremap <F5> <ESC>:!python %<CR>
"     au FileType nim nnoremap <F5> <ESC>:!nim c -r %<CR>
"     au FileType rust nnoremap <F5> <ESC>:!cargo run<CR>
" augroup END
