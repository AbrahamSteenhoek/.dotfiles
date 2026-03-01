" ===================================================================
"  Base Vim Settings (Synced from Neovim)
" ===================================================================

set nocompatible

" Full terminal color support
silent! if has('termguicolors')
    set termguicolors
endif
silent! colorscheme habamax

" UI Settings
set number
silent! set norelativenumber
set cursorline
set nowrap " do not wrap lines
set scrolloff=8 " # lines padded vertically from cursor
silent! set sidescrolloff=8 " # lines padded horizontally from cursor

" Indentation
set tabstop=4 " tabwidth
set softtabstop=4 " soft tab stop not tabs on tab/backspace
set shiftwidth=4 " indent width
set expandtab " spaces instead of tabs
set smartindent " smart auto-indent
set autoindent " copy indent from current line

" Configure the specific characters to use
set list " Enable the display of listchars
" Note: 'lead' is Neovim-specific or very recent Vim; using compatible set
silent! set listchars=tab:>·,trail:·,nbsp:␣,extends:»,precedes:«

" Search settings
set ignorecase " case-insensitive search
set smartcase " case sensitive if uppercase in string
set hlsearch " highlight search match
set incsearch " move cursor to match as you type

" Misc UI
silent! if has('patch-8.1.1564')
    set signcolumn=yes " always show a sign column
endif
silent! set colorcolumn=100 " show a col at 100 position chars
set showmatch " highlights matching brackets
set cmdheight=1 " single line cmdline
silent! set completeopt=menuone,noinsert,noselect " completion options
set noshowmode " do not show mode, instead display in statusline
silent! if exists('&pumheight')
    set pumheight=10 " popup menu height
endif
set lazyredraw " do not redraw during macros
silent! set synmaxcol=300 " syntax highlighting limit
silent! if has('patch-8.2.2508')
    set fillchars=eob:\ 
endif

" Undo settings
silent! if has('persistent_undo')
    if !isdirectory(expand("~/.vim/undodir"))
        call mkdir(expand("~/.vim/undodir"), "p")
    endif
    set undodir=~/.vim/undodir
    set undofile
endif

set nobackup " no backup files
set nowritebackup " don't write to backup files
set noswapfile " no swap files
set updatetime=50 " faster completion
set timeoutlen=300 " timeout duration
set ttimeoutlen=0 " key code timeout
set autoread " auto-reload changes if file is updated outside
set autowrite " auto-save

set hidden " allow hidden buffers
set noerrorbells " error bells are annoying
set visualbell
set t_vb=
set backspace=indent,eol,start " better backspace behavior
set noautochdir " keep original dir as cwd
silent! set iskeyword+=- " include - in words
set path+=** " include subdirs in search
set selection=inclusive " include last char in selection
set mouse=a " enable mouse support
silent! if has('clipboard')
    set clipboard=unnamedplus " use system clipboard
endif
set encoding=utf-8 " char encoding

" Split settings
set splitbelow " horizontal splits go below
set splitright " vertical splits go right

" Wildmenu
set wildmenu " tab completion
silent! set wildmode=longest:full,full

set redrawtime=10000 " increase redraw tolerance
set maxmempattern=20000 " increase max memory

" ===================================================================
"  Keymaps (remaps)
" ===================================================================
silent! let mapleader = ","
silent! let localleader = ","

" Better movement around wrapped text
silent! nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
silent! nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

" Use simple mappings for tiny vim compatibility where <expr> or <leader> might fail
nnoremap <leader><space> :nohlsearch<CR>

" Paste/Delete without yanking
xnoremap <leader>p "_dP
nnoremap <leader>x "_d
vnoremap <leader>x "_d

" Clipboard mappings
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Keep cursor centered during jumps
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Resize windows
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" Move lines
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Join lines centered
nnoremap J mzJ`z
" Fat-finger fix
nnoremap Wq :wq<CR>
" Disable Ex mode
nnoremap Q <Nop>

" Netrw
nnoremap <leader>pv :Ex<CR>

" ===================================================================
"  AutoCmds
" ===================================================================
augroup UserConfig
    autocmd!
    " Restore last cursor position
    autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif

    " Wrap, linebreak and spellcheck on markdown/text files
    autocmd FileType markdown,text,gitcommit setlocal wrap linebreak spell

    " Verilog syntax matching (from original vimrc)
    autocmd BufNewFile,BufRead *.v,*.sv,*.vs set syntax=verilog
augroup END

" Custom commands
silent! command! Wq wq
silent! command! WQ wq

" Syntax and Filetype
silent! syntax enable
silent! filetype plugin indent on

" ===================================================================
"  Statusline (Mimicking Neovim information)
" ===================================================================
set laststatus=2
silent! set statusline=\ %{toupper(mode())}\ \|\ %f\ %m%r%=l:%l\ \|\ c:%c\ \ %P\ 
