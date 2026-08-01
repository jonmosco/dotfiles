require("conform").setup({
    format_on_save = {
        timeout_ms = 5000,
        lsp_format = "fallback",
    },
    formatters_by_ft = {
        go = { "gofmt" },
        lua = { "stylua" },
        python = { "black" },
    },
})

vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })
