set nocompatible
syntax on
colorscheme ron

set smartindent
set noexpandtab smarttab

set tabstop=8
set shiftwidth=4
set sts=4
set laststatus=2
set cmdheight=1
set backspace=2

set hlsearch
set incsearch
set noignorecase
set smartcase
set showmatch

set laststatus=2
set showcmd
set showmode
set statusline=[%n]\ %f\ %y%h%w%m%r\ 0x%B(%b)\ <%l\,%c%V>%L
set autowrite nobackup nowritebackup
set nonumber
set wildmenu
set wrap
set listchars=tab:!.,trail:-
set expandtab
set formatoptions+=mM
set vb t_vb=

autocmd BufWritePost  * sleep 1
autocmd BufWritePost  * checktime
set autoread
