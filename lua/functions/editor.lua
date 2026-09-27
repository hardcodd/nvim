local M = {}
local guide_namespace = vim.api.nvim_create_namespace("IndentGuides")
local guide_provider_registered = false
local two_space_filetypes = {
  css = true,
  html = true,
  htmldjango = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  lua = true,
  markdown = true,
  scss = true,
  svelte = true,
  toml = true,
  typescript = true,
  typescriptreact = true,
  vue = true,
  xml = true,
  yaml = true,
}

--- Render space guides for visible lines without storing marks in the buffer.
--- Redraw callbacks read the current indent width, so edits and option changes stay in sync.
---@return nil
local function register_guide_provider()
  if guide_provider_registered then return end
  vim.api.nvim_set_decoration_provider(guide_namespace, {
    on_win = function(_, win, buf)
      return vim.bo[buf].buftype == "" and vim.wo[win].list
    end,
    on_range = function(_, _, buf, first_row, _, end_row, end_col)
      local last_row = end_col == 0 and end_row - 1 or end_row
      if last_row < first_row then return end
      local width = vim.bo[buf].shiftwidth
      if width == 0 then width = vim.bo[buf].tabstop end
      local lines = vim.api.nvim_buf_get_lines(buf, first_row, last_row + 1, false)
      for index, line in ipairs(lines) do
        local spaces = line:match("^( +)[^ \t]")
        if spaces then
          local complete = math.floor(#spaces / width)
          local remainder = #spaces % width
          local chunks = {}
          if complete > 0 then
            chunks[#chunks + 1] = {
              string.rep("│" .. string.rep(" ", width - 1), complete), "Whitespace",
            }
          end
          if remainder > 0 then
            chunks[#chunks + 1] = { string.rep("·", remainder), "IndentRemainder" }
          end
          vim.api.nvim_buf_set_extmark(buf, guide_namespace, first_row + index - 1, 0, {
            ephemeral = true,
            virt_text = chunks,
            virt_text_pos = "overlay",
            hl_mode = "combine",
          })
        end
      end
    end,
  })
  guide_provider_registered = true
end

--- Show quiet guides for complete levels and dots for an incomplete final level.
--- Mixed leading tabs and spaces retain one window-local warning at their transition.
---@return nil
function M.update_indent_guides()
  register_guide_provider()
  for _, id in ipairs(vim.w.indent_warning_match_ids or {}) do
    pcall(vim.fn.matchdelete, id)
  end
  vim.w.indent_warning_match_ids = {}
  if vim.bo.buftype ~= "" then
    vim.wo.list = false
    return
  end

  vim.wo.listchars = "tab:  ,leadtab:│ "
  vim.wo.list = true
  local patterns = {
    [[^ \+\zs\t]],
    [[^\t\+\zs ]],
  }
  local ids = {}
  for _, pattern in ipairs(patterns) do
    ids[#ids + 1] = vim.fn.matchadd("IndentWarning", pattern, 10)
  end
  vim.w.indent_warning_match_ids = ids
end

--- Return the configured indent width and whether a filetype requires literal tabs.
---@param filetype string
---@return integer, boolean
function M.indentation_defaults(filetype)
  if filetype == "go" or filetype == "make" then return 8, true end
  return two_space_filetypes[filetype] and 2 or 4, false
end

--- Apply language indentation defaults to a normal editing buffer.
--- Project EditorConfig settings may override these defaults afterwards.
---@param event { buf: integer }
---@return nil
function M.configure_indentation(event)
  local options = vim.bo[event.buf]
  if options.buftype ~= "" then return end
  local width, literal_tabs = M.indentation_defaults(options.filetype)
  options.shiftwidth = width
  options.tabstop = width
  options.softtabstop = literal_tabs and 0 or -1
  options.expandtab = not literal_tabs
end

--- Briefly highlight the text copied by TextYankPost.
function M.highlight_yank()
  vim.highlight.on_yank()
end

--- Restore a valid last-position mark after reading a normal file.
---@param event vim.api.keyset.create_autocmd.callback_args
function M.restore_position(event)
  local last_position = vim.api.nvim_buf_get_mark(event.buf, '"')
  local last_line = last_position[1]
  if vim.bo[event.buf].buftype == "" and last_line > 0
    and last_line <= vim.api.nvim_buf_line_count(event.buf) then
    vim.api.nvim_win_set_cursor(0, { last_line, last_position[2] })
  end
end

return M
