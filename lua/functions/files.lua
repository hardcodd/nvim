local M = {}

---@param buf integer
---@return boolean
local function is_file_browser(buf)
  return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "netrw"
    and type(vim.b[buf].netrw_curdir) == "string"
end

--- Focus an existing browser or restore its hidden buffer without losing edits.
--- Only create a new browser when no loaded local browser exists.
function M.open()
  if is_file_browser(vim.api.nvim_get_current_buf()) then return end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_file_browser(vim.api.nvim_win_get_buf(win)) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_file_browser(buf) then
      if vim.bo.modified and not vim.o.hidden then vim.cmd.split() end
      vim.api.nvim_win_set_buf(0, buf)
      return
    end
  end
  vim.cmd.Explore()
end

return M
