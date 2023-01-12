" Fix windows terminal cursor
" to fix cursor shape in WSL bash add
" echo -ne "\e[2 q"
" to .bashrc
if &term =~ "xterm"
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[2 q"
endif

" Set compatibility to Vim only
set nocompatible

""" Vundle setup

" Helps force plug-ins to load correctly when it is turned back on below.
filetype off

" start vim-plug setup
call plug#begin('$HOME/.vim/plugged/')

" Put plugins here
Plug 'dense-analysis/ale'
Plug 'easymotion/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'posva/vim-vue'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-surround'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()

" For plug-ins to load correctly
filetype plugin indent on

" Turn on syntax highlighting
syntax on

" Allow the use of mouse for transition
set mouse=a

" Display 5 lines around cursor when scrolling with a mouse.
" Solve backspace problem by setting it as the default value
set backspace=indent,eol,start

" Display mode and command
set showmode
set showcmd

" Command line completion
set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.

" make it so unsaved file in the buffer is hidden when a new file open
set hidden

" Search settings
set ignorecase                    " Include matching uppercase with lowercase search terms
set smartcase                     " Include only uppercase words with uppercase search term
set hlsearch
set incsearch

set number relativenumber
set ruler

" Automatically wrap text that extends beyond the screen length.
set wrap

set title                         " Set the terminal's title

set visualbell                    " No beeping.

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
set directory=$HOME/.vim/tmp//,.  " Keep swap files in one location

set laststatus=2                  " Show the status line all the time

" Max character count for files
set textwidth=119

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

" Speed up scrolling
set ttyfast

" Status bar
set laststatus=2

set matchpairs+=<:>               " Highlight matching brackets
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
set encoding=utf-8

" Useful status information at bottom of screen
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ [BUFFER=%n]\ %{strftime('%c')}

" Increase info size
set viminfo='100,<9999,s100

" Pane split settings
set splitbelow
set splitright

""" Plugin Settigns

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
