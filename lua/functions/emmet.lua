local M = {}

---@return vim.lsp.Client?
local function client_for_buffer()
  return vim.lsp.get_clients({ bufnr = 0, name = "emmet_language_server" })[1]
end

local function insert_tab()
  vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "in", false)
end

--- Expand the server's current abbreviation only while text, cursor and mode still match.
--- Called outside expression mappings so buffer edits and snippet selection are safe.
function M.expand()
  local client = client_for_buffer()
  if not client then return insert_tab() end
  local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
  local tick, cursor = vim.b.changedtick, vim.api.nvim_win_get_cursor(0)
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  params.context = { triggerKind = vim.lsp.protocol.CompletionTriggerKind.Invoked }
  local sent = client:request("textDocument/completion", params, function(err, result)
    if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_get_current_win() ~= win
      or vim.api.nvim_get_current_buf() ~= buf or vim.b[buf].changedtick ~= tick
      or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), cursor)
      or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      return
    end
    if err then
      vim.notify("Emmet: " .. err.message, vim.log.levels.WARN)
      return insert_tab()
    end
    local item = result and (result.items or result)[1]
    local edit = item and item.textEdit
    local range = edit and (edit.range or edit.replace)
    if not range or not vim.deep_equal(range["end"], params.position)
      or range.start.line ~= params.position.line then
      return insert_tab()
    end
    local line = vim.api.nvim_get_current_line()
    local col = vim.str_byteindex(line, client.offset_encoding, range.start.character, false)
    vim.lsp.util.apply_text_edits({ { range = range, newText = "" } }, buf, client.offset_encoding)
    vim.api.nvim_win_set_cursor(win, { range.start.line + 1, col })
    vim.snippet.expand(edit.newText)
  end, buf)
  if not sent then insert_tab() end
end

--- Accept a chosen completion, jump a snippet field, expand Emmet, or indent normally.
---@return string
function M.tab()
  local popup = vim.fn.pumvisible() == 1
  if popup and vim.fn.complete_info({ "selected" }).selected >= 0 then return "<C-y>" end
  local dismiss = popup and "<C-e>" or ""
  if vim.snippet.active({ direction = 1 }) then
    return dismiss .. "<Cmd>lua vim.snippet.jump(1)<CR>"
  end
  local mode = vim.api.nvim_get_mode().mode
  if mode == "s" or mode == "S" or mode == "\19" then return "<Tab>" end
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if client_for_buffer() and vim.api.nvim_get_current_line():sub(1, col):find("%S$") then
    return dismiss .. "<Cmd>lua require('functions.emmet').expand()<CR>"
  end
  return dismiss .. "<Tab>"
end

---@return string
function M.backtab()
  if vim.snippet.active({ direction = -1 }) then
    local dismiss = vim.fn.pumvisible() == 1 and "<C-e>" or ""
    return dismiss .. "<Cmd>lua vim.snippet.jump(-1)<CR>"
  end
  return "<S-Tab>"
end

return M
