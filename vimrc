" TODO
" - fix color scheme [DONE 1/5/12]
" - create own color scheme
"   NOTE: Switched to Solarized
" - Better Perl support
" - SVN [DONE 1/3/12]
" - comment everything!
" - move comments to the right
" - screen color support [DONE 1/30/12]
" - copy/paste for Mac OS X [DONE 1/7/12]
"   MacVim handles this perfectly
" - Fix indenting for Python [DONE 1/8/12]
" - Fix indenting
" - Fix indenting for Puppet [DONE 2/21/2013]
" - Better keybindings
" - Remove old junk!
" - Use powerline [DONE 7/30/13]
" - Use Softabs [DONE 8/2/13]

" Global Settings
set encoding=utf-8
set number                      " line numbers
set nocompatible                " always Vim mode
set ls=2                        " show the status line
set hlsearch                    " search highlighting
set incsearch                   " search as you type
set ruler                       " show the cursor position
set vb t_vb=                    " go away BELLS
set noerrorbells                " Please be quiet
set sc                          " show current command
set directory=~/.backups/       " swap file location
set redraw optimize             " Keep the screen tidy
set history=15000               " history lines
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

filetype on
filetype plugin indent on

" Set the size of the window
" Not sure if this can detech which monitor we are on
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

" Pathogen
call pathogen#infect()

" Solarized theme
syntax enable
set background=dark
colorscheme solarized
"let g:solarized_termcolors=16
let g:solarized_diffmode="high"

let g:airline_enable_branch=1
let g:airline_enable_syntastic=1
let g:airline_theme='solarized'
let g:airline_powerline_fonts=1
set fillchars+=stl:\ ,stlnc:\

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_show = 0
"let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline#extensions#tabline#buffer_nr_format = '%s: '
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tabline#fnamecollapse = 1

let g:airline#extensions#tabline#tab_nr_type = 0 " tab number
"let g:airline#extensions#tabline#show_buffers = 0

" NERDtree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeMapOpenInTab='\r'
let NERDChristmasTree=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
map <Leader>n :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Open where we last edited
autocmd BufReadPost *
\ if ! exists("g:leave_my_cursor_position_alone") |
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\ exe "normal g'\"" |
\ endif | endif

" Tips from Damian Conway for formatting
" from Perl Best Practices, and the Perl Monks
" color complex things
let perl_extended_vars = 1
let perl_include_pod = 1

" Python tabs
autocmd FileType python setl shiftwidth=4 tabstop=4

" Tabs: Needs some work
" soft tabs, or tabs made up of space characters
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Ruby
autocmd FileType ruby setl tabstop=2 shiftwidth=2 softtabstop=2 expandtab

" Allow % to bounce between angles too
set matchpairs+=<:>

" Unset the last search pattern by hitting return
nnoremap <CR>   :noh<CR><CR>

" End of Line niceness
set list
set listchars=tab:▸\ ,trail:☠

" Undo path
nnoremap <F5> :GundoToggle<CR>

" Turn off the annoying auto comment feature
autocmd FileType * setlocal formatoptions-=ro

" Teach Vim to syntax highlight Vagrantfiles and Gemfiles properly.
autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby
autocmd BufNewFile,BufRead Gemfile set filetype=ruby

" tabline colors
"hi TabLine      ctermfg=Black  ctermbg=Green     cterm=NONE
"hi TabLineFill  ctermfg=Black  ctermbg=Blue     cterm=NONE
"hi TabLineSel   ctermfg=White  ctermbg=DarkBlue  cterm=NONE

" Easy switching for buffers since I use them the most
" Switch Tabs
"map <C-K> gt
"map <C-J> gT
map <C-J> :bprev<CR>  " previous buffer
map <C-K> :bnext<CR>  " next buffer

" Easy Expansion of the Active File Directory
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Enable profiling
"nnoremap <silent> <leader>DD :exe ":profile start profile.log"<cr>:exe ":profile func *"<cr>:exe ":profile file *"<cr>
"nnoremap <silent> <leader>DQ :exe ":profile pause"<cr>:noautocmd qall!<cr>

" change cursor to flat bar like gvim
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

" mute highlighting
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
