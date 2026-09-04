vim.g.dracula_colorterm = 0
vim.cmd("colorscheme dracula_pro")

vim.api.nvim_set_hl(0, "LineNr", { fg = "#6272a4", bg = "#2f3141" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#2f3141" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f1fa8c", bg = "#2f3141", bold = true })
