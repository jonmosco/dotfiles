require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "go", "lua", "python", "vim", "vimdoc", "query", "rust", "typescript" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
