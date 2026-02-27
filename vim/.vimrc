" User interface
set nocompatible
set ruler
set laststatus=2
set wildmenu
set number
set title
set background=dark
set path+=**
set noerrorbells
set visualbell
set t_vb=

" Reading settings
set nowrap
set fileencoding=utf-8
" Fixed formatting error: assigned '~' to nbsp
set listchars=tab:>.,nbsp:~,trail:.
set cursorline

" Split settings
set splitbelow
set splitright

" Indentation
set expandtab
set noshiftround
set shiftwidth=4
set tabstop=4
set softtabstop=4
set smarttab

" Search settings
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch

" Misc.
set hidden
set noswapfile
set scrolloff=10 

nnoremap Q <Nop>

" Switching Splits
nnoremap <C-j> <C-w><down>
nnoremap <C-k> <C-w><up>
nnoremap <C-h> <C-w><left>
nnoremap <C-l> <C-w><right>

" ===================================================================
" SAFE EXECUTION BLOCK
" Wrapped in silent! to prevent E319 errors on barebones environments
" ===================================================================
silent! syntax enable
silent! filetype plugin indent on
silent! let mapleader = ','

" Verilog syntax matching
silent! autocmd BufNewFile,BufRead *.v,*.sv,*.vs set syntax=verilog

" Leader mappings
nnoremap <leader>ff :find<space>
nnoremap <leader>l :ls<cr>
nnoremap <leader>b :b <space>
nnoremap <leader>] :bn<cr>
nnoremap <leader>[ :bp<cr>
nnoremap <leader><space> :nohlsearch<cr>
nnoremap <leader>a :%y<cr>
