vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "term://*",
  callback = function()
    vim.schedule(function()
      vim.cmd("redraw!")
    end)
  end,
})