set shell=/bin/zsh 
set shiftwidth=4 
set tabstop=4
set expandtab
set textwidth=0
set autoindent
set hlsearch
set clipboard=unnamed
syntax on

call plug#begin()
Plug 'ntk148v/vim-horizon'
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()


" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" if you don't set this option, this color might not correct
set termguicolors

colorscheme horizon

" lightline
let g:lightline = {}
let g:lightline.colorscheme = 'horizon'


let g:gitgutter_highlight_lines = 1

" 補完設定
" （参考）https://qiita.com/totto2727/items/d0844c79f97ab601f13b
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
inoremap <silent><expr> <c-space> coc#refresh()
