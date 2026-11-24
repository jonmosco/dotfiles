-- Terminal-mode <Esc> is handled in after/plugin/toggleterm.lua, which skips
-- claude buffers so Esc passes through. This file used to re-map it too.
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