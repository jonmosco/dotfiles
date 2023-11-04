-- Lazy plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
   {'tjdevries/colorbuddy.nvim'},
   {'navarasu/onedark.nvim'},
   {
       'nvim-telescope/telescope.nvim', tag = '0.1.4',
       dependencies = { 'nvim-lua/plenary.nvim' }
   },

   {
       "someone-stole-my-name/yaml-companion.nvim",
       ft = { "yaml" },
       opts = {
           builtin_matchers = {
               kubernetes = { enabled = true },
           },
       },
       dependencies = {
           { "neovim/nvim-lspconfig" },
           { "nvim-lua/plenary.nvim" },
           { "nvim-telescope/telescope.nvim" },
       },
       config = function(_, opts)
           local cfg = require("yaml-companion").setup(opts)
           require("lspconfig")["yamlls"].setup(cfg)
           require("telescope").load_extension("yaml_schema")
       end,
   },

   {'nvim-telescope/telescope-ui-select.nvim'},
   {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
   {'mbbill/undotree'},
   {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
   {'williamboman/mason.nvim'},
   {'williamboman/mason-lspconfig.nvim'},
   {'neovim/nvim-lspconfig'},
   {'hrsh7th/cmp-nvim-lsp'},
   {'hrsh7th/nvim-cmp'},
   {'L3MON4D3/LuaSnip'},
   {'hrsh7th/cmp-buffer'},
   {'hrsh7th/cmp-path'},
   {'hrsh7th/cmp-cmdline'},
   {'rafamadriz/friendly-snippets'},
   {'ThePrimeagen/harpoon'},
   {'folke/neodev.nvim', opts = {} },

   {
       'nvim-lualine/lualine.nvim',
       dependencies = { 'nvim-tree/nvim-web-devicons' }
   },

   {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

   "nvim-tree/nvim-tree.lua",
   version = "*",
   lazy = false,
   dependencies = {
       "nvim-tree/nvim-web-devicons",
   },
   config = function()
       require("nvim-tree").setup {}
   end,

   { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

   -- vim plugins
   {'tpope/vim-commentary'},
   {'tpope/vim-fugitive'},
   {'tpope/vim-projectionist'},


})
