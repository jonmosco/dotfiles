local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})

require('mason-lspconfig').setup({
  ensure_installed = { 'ansiblels', 'clangd', 'gopls', 'lua_ls', 'tsserver', 'rust_analyzer', 'yamlls' },
  handlers = {
    lsp_zero.default_setup,
    ["lua_ls"] = function ()
        local lspconfig = require("lspconfig")
        lspconfig.lua_ls.setup {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            }
        }
    end,
  },
})
