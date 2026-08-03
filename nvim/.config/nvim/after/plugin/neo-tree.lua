require("neo-tree").setup({
    window = {
        width = 30,
    },
    filesystem = {
        filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },
})

vim.keymap.set("n", "<C-t>", "<cmd>Neotree toggle<cr>", { silent = true })
vim.keymap.set("n", "<leader>gs", "<cmd>Neotree float git_status<cr>", { desc = "Git status" })
