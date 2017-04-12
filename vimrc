" -----------------------------------------------------------------------------
" Global Settings
" -----------------------------------------------------------------------------

" Vundle
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'altercation/vim-colors-solarized'
Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'voxpupuli/vim-puppet'
Plugin 'scrooloose/syntastic'
Plugin 'chase/vim-ansible-yaml'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'fatih/vim-go'
Plugin 'Gundo'
Plugin 'majutsushi/tagbar'
Plugin 'ConradIrwin/vim-bracketed-paste'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'junegunn/goyo.vim'
Plugin 'tomtom/tcomment_vim'
Plugin 'nathanaelkane/vim-indent-guides'
call vundle#end()
filetype plugin indent on

set nocompatible                " always Vim mode
scriptencoding utf-8
set encoding=utf-8
set number                      " line numbers
set ls=2                        " show the status line
set hlsearch                    " search highlighting
set incsearch                   " search as you type
set ruler                       " show the cursor position
set vb t_vb=                    " go away BELLS
set noerrorbells                " Please be quiet
set sc                          " show current command
set directory=~/.backups/       " swap file location
set redraw optimize             " Keep the screen tidy
set history=10000               " history lines
set title                       " Inherit the term title from Vim
set titleold=""                 " No "Thanks for Flying Vim" message
set clipboard=unnamed
set linebreak
set hidden
set autoindent
set nosi                        " Disable 'smart'-indenting
set cursorline                  " Highlight the entire line the cursor is on
set noshowmode                  " No need since we are using powerline
"set tw=80
" Create backups.  This was learned the hard way.
set backup
set backupdir=~/.backups/
set backupext=.bak              "Append .bak to backup files
set writebackup
set backspace=indent,eol,start  " Make Backspaces delete sensibly
set smartcase                   " "Smart" searching
set ignorecase                  " Ignore case when searching


" Set the size of the window
" - if using desktop, increase font size
if has("gui_running")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    "set guifont=Monaco\ For\ Powerline:h14
    set guifont=Inconsolata-Dz\ For\ Powerline:h16
    set lines=30
    set columns=110
  endif
endif

" Solarized theme
syntax enable
set background=dark
colorscheme solarized
let g:solarized_diffmode="high"

" Airline settings
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline_theme='solarized'
let g:airline_powerline_fonts=1
set fillchars+=stl:\ ,stlnc:\
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_show = 0
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#tabline#tab_nr_type = 0 " tab number
let g:airline#extensions#tmuxline#enabled = 0

" NERDtree
map <C-n> :NERDTreeToggle<CR>

let NERDTreeMapOpenInTab='\r'
let NERDChristmasTree=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
"let NERDTreeWinPos = "right"
map <Leader>n :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Markdown
let g:vim_markdown_folding_disabled = 1

" ------------------------------------------------------------------------------
" Misc formatting
" ------------------------------------------------------------------------------

" Open where we last edited
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \ if line("'\"") > 0 && line ("'\"") <= line("$") |
      \ exe "normal g'\"" |
      \ endif | endif

" Python tabs
autocmd FileType python
      \ setl shiftwidth=4
      \ tabstop=4
      \ softtabstop=4
      \ textwidth=79

" Tabs
" soft tabs, or tabs made up of space characters
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Ruby
autocmd FileType ruby setl tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby
autocmd BufNewFile,BufRead Gemfile set filetype=ruby

" JSON
autocmd BufNewFile,BufRead *.json set ft=javascript

" Go
autocmd FileType go setlocal noet ts=8 sw=8 sts=8

" Allow % to bounce between angles too
set matchpairs+=<:>

" End of Line niceness
set list
set listchars=tab:\ \ ,trail:☠
"set listchars=tab:▸\ ,trail:☠

" Turn off the annoying auto comment feature
autocmd FileType * setlocal formatoptions-=ro

" ctags path
let g:tagbar_ctags_bin='/usr/local/bin/ctags'

" ------------------------------------------------------------------------------
" Custom Mappings
" ------------------------------------------------------------------------------

" Unset the last search pattern by hitting return
nnoremap <CR>   :noh<CR><CR>

" Undo path
nnoremap <F5> :GundoToggle<CR>

" Toggle Tagbar
nmap <F6> :TagbarToggle<CR>

map <C-J> :bprev<CR>  " previous buffer
map <C-K> :bnext<CR>  " next buffer

" IndentLine
let g:indentLine_char = '│'
let g:indentLine_enabled = 0
map <C-S> :IndentLinesToggle<CR> " Indent Line

" mute highlighting
nnoremap <silent> <c-l> :<c-u>nohlsearch<cr><c-l>

" Easy Expansion of the Active File Directory
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Enable profiling
"nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
"nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>

" RSpec.vim mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

let g:tmuxline_preset = {
      \'a'    : '❐ #S',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W'],
      \'x'    : '%R',
      \'y'    : ['%a', '%Y'],
      \'z'    : '#H'}

let g:tmuxline_theme = 'powerline'

" Switch back to blue
function! AirlineThemePatch(palette)
  let a:palette.normal.airline_a = [ '#ffffff', '#268bd2', 255, 33 ]
endfunction
let g:airline_theme_patch_func = 'AirlineThemePatch'

autocmd BufRead,BufNewFile *
      \  if expand('%:p:h') =~# '.*/cookbooks/.*'
      \|   setlocal makeprg=foodcritic\ $*\ %
      \|   setlocal errorformat=%m:\ %f:%l
      \| endif

" JSON
au BufRead,BufNewFile *.json set filetype=json

" Puppet ctags
let g:tagbar_type_puppet = {
  \ 'ctagstype': 'puppet',
  \ 'kinds': [
    \'c:class',
    \'s:site',
    \'n:node',
    \'d:definition',
    \'r:resource',
    \'f:default'
  \]
\}

" Go ctags
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

" Leader key by default is \
" Remap to ,
let mapleader = ","

let g:go_template_autocreate = 0
au FileType go nmap <leader>r <Plug>(go-run)


let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1
