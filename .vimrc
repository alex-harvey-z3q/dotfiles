execute pathogen#infect()
syntax on
filetype plugin indent on
set expandtab
set shiftwidth=2
set ts=2
set modelines=1
let g:vim_markdown_folding_disabled=1
let g:is_bash=1
let @a='^iimport ipdb; ipdb.set_trace()'
highlight nonascii guibg=Red ctermbg=1 term=standout
au BufReadPost * syntax match nonascii "[^\u0000-\u007F]"
au BufNewFile,BufRead *.cr setlocal ft=ruby
autocmd BufNewFile,BufRead */_posts/*.md set syntax=liquid
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
set listchars=tab:▸\ ,trail:·
set list
