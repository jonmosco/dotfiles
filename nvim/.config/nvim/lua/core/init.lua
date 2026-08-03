vim.g.mapleader = ";"

require("core.lazy-config")
require("core.remap")

vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.nu = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.incsearch = true
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.linebreak = true
vim.opt.autoindent = true
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.showmatch = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
vim.opt.signcolumn = "yes"

vim.opt.termguicolors = true

vim.opt.list = false
vim.opt.listchars = {
    tab = "→ ",
    trail = "☠"
}

vim.cmd([[autocmd FileType * set formatoptions-=ro]])

vim.lsp.enable({ 'gopls', 'pyright', 'lua_ls', 'bashls' })

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.INFO] = "●",
            [vim.diagnostic.severity.HINT] = "●",
        },
    },
    virtual_text = false,
    underline = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local wins = vim.api.nvim_list_wins()
        local file_wins = 0
        for _, w in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(w)
            local bt = vim.bo[buf].buftype
            if bt == "" or bt == "acwrite" then
                file_wins = file_wins + 1
            end
        end
        if file_wins == 0 then
            vim.cmd("quitall")
        end
    end,
})

vim.keymap.set("n", "<C-J>", "<cmd>bprev<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<C-K>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
