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
