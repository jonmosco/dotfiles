vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name:find("claude") then
      vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true, noremap = true })
    end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ClaudeCodeSendComplete",
  callback = function(ev)
    local data = ev.data or {}
    local msg = "Sent to Claude: " .. (data.file_path or "selection")
    if data.start_line and data.end_line then
      msg = msg .. " (lines " .. (data.start_line + 1) .. "-" .. (data.end_line + 1) .. ")"
    end
    vim.notify(msg, vim.log.levels.INFO)
  end,
})