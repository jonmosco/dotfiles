require("conform").setup({
    format_on_save = false,
    formatters_by_ft = {
        go = { "gofmt" },
        lua = { "stylua" },
        python = { "black" },
    },
})

-- <leader>cf, not <leader>f: the latter is a prefix of the <leader>f* Telescope
-- maps, so every format waited out 'timeoutlen' first.
vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ bufnr = 0 })
end, { desc = "Format buffer" })
