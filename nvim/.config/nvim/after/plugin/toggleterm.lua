require("toggleterm").setup({
    open_mapping = [[<C-\>]],
    direction = "horizontal",
    size = 15,
})

local Terminal = require("toggleterm.terminal").Terminal
local float_term = Terminal:new({ direction = "float", float_opts = { border = "rounded" } })
vim.keymap.set("n", "<leader>tf", function() float_term:toggle() end, { desc = "Toggle floating terminal" })

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end,
})
