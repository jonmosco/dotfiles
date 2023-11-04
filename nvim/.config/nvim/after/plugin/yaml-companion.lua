local cfg = require("yaml-companion").setup({
    schemas = {
        name = "qontract-reconcile",
        uri = "https://raw.githubusercontent.com/app-sre/qontract-schemas/main/schemas/common-1.json",
    },
    lspconfig = {
        settings = {
            schemaDownload = { enable = true },
            schemas = {
                name = "qontract-reconcile",
                uri = "https://raw.githubusercontent.com/app-sre/qontract-schemas/main/schemas/common-1.json",
            },
            trace = { server = "debug" },
        },
    },
})
require("lspconfig")["yamlls"].setup(cfg)

local function get_schema()
  local schema = require("yaml-companion").get_buf_schema(0)
  if schema.result[1].name == "none" then
    return ""
  end
  return schema.result[1].name
end

--  ~/.config/nvim/lua/waylonwalker/lsp-config.lua
-- require'lspconfig'.yamlls.setup{
--     on_attach=on_attach,
--     capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
--     settings = {
--         yaml = {
--             schemas = {
--                 ["https://raw.githubusercontent.com/quantumblacklabs/kedro/develop/static/jsonschema/kedro-catalog-0.17.json"]= "conf/**/*catalog*",
--                 ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
--             }
--         }
--     }
-- }

-- configure yamlls ls:
-- require('lspconfig')['yamlls'].setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     yaml = {
--       schemas = {
--         ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.yaml"] = "/*"
--       }
--     }
--   }
-- }
