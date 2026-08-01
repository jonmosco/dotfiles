-- Favorite remaps

-- retain your original paste register to continue to apply the same changes over and over
vim.keymap.set("v", "p", '"_dP')

vim.keymap.set("n", "<leader>w", "<cmd>bp|bd #<CR>", { desc = "Close Buffer; Retain Split" })

-- terminal remaps
-- vim.api.nvim_set_keymap('t', [[<esc> <C-\><C-n>]], { noremap = true })
-- vim.api.nvim_set_keymap('t', '<c-v><esc>', [[<c-\><c-n>]], { noremap = true })
