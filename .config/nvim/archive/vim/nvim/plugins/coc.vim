"" coc.nvim
""" <Tab>で候補をナビゲート
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" autocomplete
inoremap <silent><expr> <C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <silent><expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
inoremap <silent><expr> <Enter> coc#pum#visible() ? coc#pum#confirm() : "\<Enter>"
inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"
inoremap <silent><expr> <C-h> coc#pum#visible() ? coc#pum#cancel() : "\<C-h>"

" <Tab>で次、<S+Tab>で前
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1):
  \ <SID>check_back_space() ? "\<Tab>" :
  \ coc#refresh()

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<S-TAB>" " "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()" gd: 定義ジャンプ  gy: 型定義  gi: ?  gr: 参照ジャンプ
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

command! -nargs=0 Rename :call CocActionAsync('rename')
command! -nargs=0 OpenLink :call CocActionAsync('openLink')
nmap <silent> <C-l> <ESC>:call CocActionAsync('rename')<CR>
nmap <silent> lo <ESC>:call CocActionAsync('openLink')<CR>
nmap <silent> <C-h> <ESC>:call CocActionAsync('doHover')<CR>

" 補完ウィンドウをスクロール
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1, 1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0, -1)\<cr>" : "\<Left>"

" gp: 前のバッファファイルへ  gn: 次のバッファファイルへ
nnoremap <silent> gp :bprevious<CR>
nnoremap <silent> gn :bnext<CR>
" [w 次の警告へ ]w 前の警告へ
nmap <silent> [w <Plug>(coc-diagnostic-next)
nmap <silent> ]w <Plug>(coc-diagnostic-prev)

command! -nargs=0 Format :call CocAction('format')
augroup cocfmt
	autocmd!
	autocmd BufWritePre *.cpp,*.c,*.h,*.js,*.ts,*.tsx,*.py,*.html,*.cs,*.json,*.toml :call CocAction('format')
augroup END

" coc-rust-analyzer
"For Types hint 
"hi default CocRustTypeHint guibg=Red guifg=#d7875f ctermbg=238 ctermfg=74 cterm=italic   
""Others hint 
"hi default CocRustChainingHint guibg=Red guifg=Blue ctermbg=0 ctermfg=8

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
