" -----------------------------------------------------------------------------
" Global Settings
" -----------------------------------------------------------------------------

" Plugins - managed with vim-plug
call plug#begin()
Plug 'pearofducks/ansible-vim'
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
Plug 'scrooloose/syntastic'
Plug 'godlygeek/tabular'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'junegunn/goyo.vim'
Plug 'tomtom/tcomment_vim'
Plug 'google/vim-searchindex'
Plug 'hashivim/vim-terraform'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'rust-lang/rust.vim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'fatih/vim-go'
Plug 'overcache/NeoSolarized'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
" Plug 'romgrk/barbar.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'tpope/vim-projectionist'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
call plug#end()

set nocompatible                " always Vim mode
scriptencoding utf-8
set encoding=utf-8
set number                      " line numbers
set ls=2                        " show the status line
set hlsearch                    " search highlighting
set incsearch                   " search as you type
set ruler                       " show the cursor position
set noerrorbells                " go away BELLS
set noerrorbells                " Please be quiet
set sc                          " show current command
set directory=~/.backups/       " swap file location
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
set backup                      " Create backups.  This was learned the hard way.
set backupdir=~/.backups/
set backupext=.bak              "Append .bak to backup files
set writebackup
set backspace=indent,eol,start  " Make Backspaces delete sensibly
set smartcase                   " "Smart" searching
set ignorecase                  " Ignore case when searching

if has("termguicolors")
    set termguicolors
endif

" Set the size of the window
" If using desktop, increase font size
if has("gui_running")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    set guifont=Inconsolata-Dz\ For\ Powerline:h16
    set lines=30
    set columns=110
  endif
endif

" Solarized theme
set background=dark
colorscheme NeoSolarized
highlight CursorLineNr cterm=bold ctermfg=220

" Syntastic
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 0

" fzf
" Files command with preview window
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
nnoremap <silent> <Leader><Leader> :Files<CR>
nnoremap <C-p> :Files<CR>

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
      \ expandtab

" Tabs
" soft tabs, or tabs made up of space characters
set expandtab
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4

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

" Turn off the annoying auto comment feature
autocmd FileType * setlocal formatoptions-=ro

" --------------------------------------------------------------------
" Custom Mappings
" --------------------------------------------------------------------

" Leader key by default is \
" Remap to ,
let mapleader = ","

" Close Buffer
nnoremap <Leader>q :Bdelete<CR>

" Unset the last search pattern by hitting return
nnoremap <CR>   :noh<CR><CR>

" Undo path
nnoremap gU :GundoToggle<CR>

" mute highlighting
nnoremap <silent> <c-l> :<c-u>nohlsearch<cr><c-l>

" Toggle Tagbar
nmap tT :TagbarToggle<CR>

" insert a literal tab
inoremap <S-Tab> <C-V><Tab>

map <C-J> :bprev<CR>  " previous buffer
map <C-K> :bnext<CR>  " next buffer

" JSON
au BufRead,BufNewFile *.json set filetype=json

let g:go_template_autocreate = 0
au FileType go nmap <leader>r <Plug>(go-run)

" Jenkinsfile
au BufReadPost Jenkinsfile set syntax=groovy
au BufReadPost Jenkinsfile set filetype=groovy

let g:move_key_modifier = 'C'

lua <<EOF
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
-- Open NvimTree
vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeToggle<cr>", {silent = true, noremap = true})

require('lualine').setup{
    options = {
        theme = 'solarized_dark',
        section_separators = { left = ' ' , right = ' ' },
    }
}

require('bufferline').setup{
    options = {
        separator_style = "slant"
    }
}

require('tree-close')
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#b58900'} )
EOF
