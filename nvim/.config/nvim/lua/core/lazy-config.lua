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
   { dir = vim.fn.stdpath("data") .. "/site/pack/themes/start/dracula_pro" },
   {
       'nvim-telescope/telescope.nvim', branch = '0.1.x',
       dependencies = { 'nvim-lua/plenary.nvim' }
   },
   {'nvim-telescope/telescope-ui-select.nvim'},
   {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},
   {'mbbill/undotree'},
   {'neovim/nvim-lspconfig'},
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
   {'folke/which-key.nvim', event = "VeryLazy"},
   {'akinsho/toggleterm.nvim', version = "*"},
   {
       'iamcco/markdown-preview.nvim',
       cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
       ft = { "markdown" },
       build = function() vim.fn["mkdp#util#install"]() end,
   },

   -- vim plugins
   {'tpope/vim-commentary'},
   {'tpope/vim-fugitive'},
   {'tpope/vim-projectionist'},

}, {
    rocks = { enabled = false },
})
