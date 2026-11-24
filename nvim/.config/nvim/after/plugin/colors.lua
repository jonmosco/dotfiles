vim.g.dracula_colorterm = 0

-- Dracula Pro is a paid theme and is not committed to this repo, so it may be
-- absent on a fresh machine. Without this guard the bare colorscheme call
-- raises E185 on every startup. The gutter overrides below are tuned to the
-- Pro palette, so skip them when falling back.
if not pcall(vim.cmd.colorscheme, "dracula_pro") then
    pcall(vim.cmd.colorscheme, "habamax")
    return
end

vim.api.nvim_set_hl(0, "LineNr", { fg = "#6272a4", bg = "#2f3141" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "#2f3141" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f1fa8c", bg = "#2f3141", bold = true })
