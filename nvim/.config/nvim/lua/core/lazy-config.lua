-- Lazy plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
   { dir = vim.fn.stdpath("data") .. "/dracula_pro" },
   { 'folke/snacks.nvim', lazy = false, priority = 1000, opts = { scroll = { enabled = true } } },
   { 'j-hui/fidget.nvim', opts = {} },
   { 'folke/trouble.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' }, opts = {} },
   { 'rcarriga/nvim-notify', config = function()
       local notify = require("notify")
       notify.setup({
           stages = "fade",
           timeout = 3000,
           top_down = true,
           background_colour = "#000000",
       })
       vim.notify = notify
   end},
   {
       'nvim-telescope/telescope.nvim', branch = '0.1.x',
       dependencies = { 'nvim-lua/plenary.nvim' }
   },
   {'nvim-telescope/telescope-ui-select.nvim'},
   {"nvim-treesitter/nvim-treesitter", branch = 'main', lazy = false,
    build = ":TSInstall bash c cpp go hcl json lua python query rust typescript vim vimdoc yaml"},
   {'mbbill/undotree'},
   {'neovim/nvim-lspconfig'},
   {'williamboman/mason.nvim'},
   {'williamboman/mason-lspconfig.nvim'},
   {'hrsh7th/nvim-cmp'},
   {'hrsh7th/cmp-nvim-lsp'},
   {'L3MON4D3/LuaSnip'},
   {'saadparwaiz1/cmp_luasnip'},
   {'hrsh7th/cmp-buffer'},
   {'hrsh7th/cmp-path'},
   {'hrsh7th/cmp-cmdline'},
   {
       'nvim-lualine/lualine.nvim',
       dependencies = { 'nvim-tree/nvim-web-devicons' }
   },

   {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

   { "nvim-neo-tree/neo-tree.nvim",
     branch = "v3.x",
     lazy = false,
     dependencies = {
         "nvim-lua/plenary.nvim",
         "MunifTanjim/nui.nvim",
         "nvim-tree/nvim-web-devicons",
     },
   },

   {'stevearc/conform.nvim'},
   {'folke/zen-mode.nvim'},
   {'folke/which-key.nvim', event = "VeryLazy", opts = { delay = 500 }},
   {'akinsho/toggleterm.nvim', version = "*"},
   {
       'iamcco/markdown-preview.nvim',
       cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
       ft = { "markdown" },
       build = function() vim.fn["mkdp#util#install"]() end,
   },

   {
       'coder/claudecode.nvim',
       dependencies = { 'folke/snacks.nvim' },

       opts = {
           diff_opts = {
               open_in_new_tab = true,
               layout = "unified",
           },
       },
       cmd = {
           "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel",
           "ClaudeCodeAdd", "ClaudeCodeSend", "ClaudeCodeTreeAdd",
           "ClaudeCodeStatus", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
       },
       keys = {
           { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
           { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
           { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
           { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
           { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
           { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
           { "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = { "neo-tree" } },
           { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
           { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
       },
   },

   -- vim plugins
   {'tpope/vim-commentary'},
   {'tpope/vim-fugitive'},
   {'tpope/vim-projectionist'},

}, {
    rocks = { enabled = false },
})
