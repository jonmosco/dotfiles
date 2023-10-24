-- NeoVim

vim.opt.nu = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.incsearch = true
vim.opt.hidden = true
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.linebreak = true
vim.opt.autoindent = true
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.relativenumber = true

vim.opt.backup = true
vim.opt.backupdir = os.getenv("HOME") .. "/.backups/"
vim.opt.backupext = ".bak"
vim.opt.writebackup = true
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
vim.opt.signcolumn = "yes"

vim.opt.termguicolors = true

-- vim.opt.list = true
vim.opt.list = false
-- vim.opt.listchars = 'tab:\ \ ,trail:☠'

vim.opt.formatoptions:remove { "c", "r", "o" }
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

vim.g.mapleader = ";"
vim.keymap.set("n", "<C-J>", "<cmd>bprev<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<C-K>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })

require("core")
