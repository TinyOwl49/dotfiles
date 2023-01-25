let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" https://knowledge.sakura.ad.jp/23248/
"
" dein.vim settings {{{
" install dir {{{
let s:dein_dir = expand('$CACHE/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('$CONFIG/nvim')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'
  " let s:lazy_toml = s:rc_dir . '/dein_lazy.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}

"------------------------------------------------------------------------------
" UI 
"------------------------------------------------------------------------------
set number
colorscheme onedark
syntax on
syntax enable
filetype plugin indent on
set hlsearch
set nowritebackup
set nobackup
set wrap
set noswapfile
set list
set colorcolumn=50
set clipboard+=unnamed

" NERDTree用の設定
" set guifont=Cica:h16
" set printfont=Cica:h12
" set ambiwidth=double
" set renderingoptions=type:directx,renmode:5
" let g:webdevicons_enable_nerdtree = 1


augroup vimrc
    autocmd!
    au BufRead,BufNewFile * set number
augroup END

" カラースキームを入れた際の背景色を透明にする
" highlight Normal ctermbg=none
" highlight NonText ctermbg=none
" highlight LineNr ctermbg=none
" highlight Folded ctermbg=none
" highlight EndOfBuffer ctermbg=none 

" augroup TransparentBG
"   	autocmd!
" 	autocmd Colorscheme * highlight Normal ctermbg=none
" 	autocmd Colorscheme * highlight NonText ctermbg=none
" 	autocmd Colorscheme * highlight LineNr ctermbg=none
" 	autocmd Colorscheme * highlight Folded ctermbg=none
" 	autocmd Colorscheme * highlight EndOfBuffer ctermbg=none 
" augroup END



" ALEがなんなのかについてよく知らないので
" let g:ale_linters = {
" \   'nim': ['nimlsp', 'nimcheck'],
" \}
" let g:ale_fixers = {
" \   '*': ['remove_trailing_lines', 'trim_whitespace'],
" \   'nim': ['nimpretty'],
" \}
" let g:ale_lint_on_save = 1
" let g:ale_lint_on_text_changed = 0
" let g:ale_lint_on_enter = 0
" let g:ale_set_loclist = 0
" let g:ale_set_quickfix = 1
" let g:ale_sign_error = '✖✖'
" let g:ale_sign_warning = '⚠⚠'
" let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']

" highlight ALEErrorSign guifg=Red
" highlight ALEWarningSign guifg=Yellow

"------------------------------------------------------------------------------
" 自作プラグインを読み込む
"------------------------------------------------------------------------------

let s:plugin_dir = expand('$CONFIG/nvim/plugins/')
let splt = split(glob(s:plugin_dir . "*.vim"))
  
for file in splt
	execute 'source' file
endfor
