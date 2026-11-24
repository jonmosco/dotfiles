require("toggleterm").setup({
    open_mapping = [[<C-\>]],
    direction = "horizontal",
    size = 15,
})

local Terminal = require("toggleterm.terminal").Terminal
local float_term = Terminal:new({ direction = "float", float_opts = { border = "rounded" } })
vim.keymap.set("n", "<leader>tf", function() float_term:toggle() end, { desc = "Toggle floating terminal" })
vim.keymap.set("n", "<leader>ta", "<cmd>ToggleTermToggleAll<cr>", { desc = "Toggle all terminals" })

-- Single owner of terminal-mode keys. Three TermOpen autocmds used to fight
-- over <Esc> (here, core/remap.lua, and claudecode.lua); which one won
-- depended on load order. Claude needs Esc itself, so skip the mapping there
-- and leave Esc at its default of passing through to the program.
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("terminal_keys", { clear = true }),
    pattern = "term://*",
    callback = function(ev)
        local opts = { buffer = ev.buf }
        if not vim.api.nvim_buf_get_name(ev.buf):find("claude") then
            vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
        end
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end,
})
