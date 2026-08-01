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
       'nvim-telescope/telescope.nvim', tag = '0.1.4',
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

   { "nvim-tree/nvim-tree.lua",
     version = "*",
     lazy = false,
     dependencies = {
         "nvim-tree/nvim-web-devicons",
     },
   },

   -- vim plugins
   {'tpope/vim-commentary'},
   {'tpope/vim-fugitive'},
   {'tpope/vim-projectionist'},

})
