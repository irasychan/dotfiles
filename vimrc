" Set compatibility to Vim only
set nocompatible

" Helps force plug-ins to load correctly when it is turned back on below.
filetype off
" Turn on syntax highlighting
syntax on

" Setup Vundle here

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Put plugins here

Plugin 'godlygeek/tabular'
Plugin 'preservim/nerdtree'
Plugin 'dense-analysis/ale'
Plugin 'plasticboy/vim-markdown'

call vundle#end()

" For plug-ins to load correctly
filetype plugin indent on

" Allow the use of mouse for transition
set mouse=a

" Turn off modeline checking for opening file with vim
set modelines=0

" Automatically wrap text that extends beyond the screen length.
set wrap

" For Toggling pasting as indent for paste doesn't work properly
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O>:set invpaste paste?<CR>
set pastetoggle=<F2>

" Max character count for files
set textwidth=79
" Highlight textwidth column
set columncolor=81

" Default formatting options
"   t        Auto-wrap text using textwidth
"   c        Auto-wrap comments
"   q        Allow 'gq' command to work for formatting
"   r        Auto insert for comment leader for new line
"   n        Numbered list formatting
"   k        Don't break 1 letter line
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Display 5 lines around cursor when scrolling with a mouse.
" Solve backspace problem by setting it as the default value
set backspace=indent,eol,start

" Speed up scrolling
set ttyfast

" Status bar
set laststatus=2

" Display mode and command
set showmode
set showcmd

" Highlight matching brackets
set matchpairs+=<:>

set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

set number relativenumber

set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}

set encoding=utf-8

set hlsearch
set incsearch
" Include matching uppercase with lowercase search terms
set ignorecase
" Include only uppercase words with uppercase search term
set smartcase

" Increase info size
set viminfo='100,<9999,s100

" Pane split settings

set splitbelow
set splitright

" Plugin Settigns

" Nerdtree Key mapping

map <C-n> :NERDTreeToggle<CR>

" ALE (Linter) Settings

let g:ale_sign_column_always          = 1
let g:ale_sign_error                  = '✘'
let g:ale_sign_warning                = '⚠'
let g:ale_linters_explicit            = 1
let g:ale_lint_on_text_changed        = 'never'
let g:ale_lint_on_enter               = 0
let g:ale_lint_on_save                = 1
let g:ale_fix_on_save                 = 1
let g:ale_linters = {
\   'markdown':      ['markdownlint', 'writegood'],
\}

let g:ale_fixers = {
\   '*':          ['remove_trailing_lines', 'trim_whitespace'],
\}
highlight ALEErrorSign ctermbg        =NONE ctermfg=red
highlight ALEWarningSign ctermbg      =NONE ctermfg=yellow

" ALE markdown linter settings

let g:ale_writegood_options = '--no-passive'

" Vim Markdown settings

set conceallevel=2

" Load all plugins from pack
packloadall
" Load all of the helptags after the plugins are loaded
silent! helptags ALL
