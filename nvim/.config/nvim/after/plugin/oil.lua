require("oil").setup({
    view_options = {
        show_hidden = true,
    },
    win_options = {
        signcolumn = "yes:2",
    },
})

require("oil-git-status").setup({})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "<C-t>", "<cmd>Oil --float<cr>", { desc = "Open Oil float" })
