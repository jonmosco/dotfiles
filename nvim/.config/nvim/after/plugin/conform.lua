require("conform").setup({
    format_on_save = false,
    formatters_by_ft = {
        go = { "gofmt" },
        lua = { "stylua" },
        python = { "black" },
    },
})

vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })
