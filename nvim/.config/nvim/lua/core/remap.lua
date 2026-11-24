-- Favorite remaps

-- retain your original paste register to continue to apply the same changes over and over
vim.keymap.set("v", "p", '"_dP')

vim.keymap.set("n", "<leader>w", "<cmd>bp|bd #<CR>", { desc = "Close Buffer; Retain Split" })
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Preview" })

vim.keymap.set("t", "<C-]>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Terminal <Esc> and the Telescope <leader>f* maps both used to live here as
-- well as in after/plugin/, so each was set twice with the later file silently
-- winning. Both now have a single owner: toggleterm.lua and telescope.lua.

-- vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
-- vim.keymap.set("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
-- vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix" })
