vim.opt.rtp:prepend(vim.fn.getcwd())

local api = vim.api
local treesitter = require("functions.treesitter")
local query = assert(vim.treesitter.query.get("html", "highlights"))
local lua_query = assert(vim.treesitter.query.get("lua", "highlights"))
local lua_iter = lua_query.iter_captures
local original_iter = query.iter_captures
local forwarded_options

query.iter_captures = function(self, node, source, start_row, end_row, options)
  forwarded_options = options
  return original_iter(self, node, source, start_row, end_row, options)
end

local lines = { "<section>" }
for level = 1, 39 do
  lines[#lines + 1] = string.rep("  ", level) .. "<div>"
end
for level = 39, 1, -1 do
  lines[#lines + 1] = string.rep("  ", level) .. "</div>"
end
lines[#lines + 1] = "</section>"

local function buffer(filetype, content)
  local buf = api.nvim_create_buf(true, false)
  api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = filetype
  api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.treesitter.start(buf)
  assert(vim.treesitter.get_parser(buf):parse(true)[1], filetype .. " parser unavailable")
  return buf
end

local function has_capture(buf, row, column, wanted)
  for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf, row, column)) do
    if capture.capture == wanted and capture.lang == "html" then return true end
  end
  return false
end

local function check_tags(buf, offset)
  api.nvim_set_current_buf(buf)
  local filetype = vim.bo[buf].filetype
  for _, row in ipairs({ 0, 19, 39, 40, 60, 79, 39, 19 }) do
    local line = api.nvim_buf_get_lines(buf, row + offset,
      row + offset + 1, false)[1]
    local name = line:find("div", 1, true) or line:find("section", 1, true)
    local delimiter = assert(line:find("<", 1, true))
    api.nvim_win_set_cursor(0, { row + offset + 1, name - 1 })
    api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
    assert(has_capture(buf, row + offset, name - 1, "tag"),
      filetype .. " tag name lost at row " .. (row + offset + 1))
    assert(has_capture(buf, row + offset, delimiter - 1, "tag.delimiter"),
      filetype .. " tag delimiter lost at row " .. (row + offset + 1))
  end
end

assert(treesitter.configure_html_highlights())
local wrapped_iter = query.iter_captures
assert(wrapped_iter ~= original_iter, "HTML query must use a higher default limit")
assert(treesitter.configure_html_highlights())
assert(query.iter_captures == wrapped_iter, "HTML query must only be wrapped once")
assert(lua_query.iter_captures == lua_iter, "other language queries must stay unchanged")

local html = buffer("html", lines)
local root = vim.treesitter.get_parser(html):parse(true)[1]:root()
query:iter_captures(root, html, 19, 20)
assert(forwarded_options and forwarded_options.match_limit == 512,
  "HTML query must raise the default in-progress match limit")
local explicit = { match_limit = 128, start_col = 3 }
query:iter_captures(root, html, 19, 20, explicit)
assert(forwarded_options.match_limit == 128 and forwarded_options.start_col == 3,
  "an explicit caller limit and other options must be preserved")
assert(vim.deep_equal(explicit, { match_limit = 128, start_col = 3 }),
  "caller options must not be mutated")
check_tags(html, 0)
assert(vim.deep_equal(api.nvim_buf_get_lines(html, 0, -1, false), lines),
  "HTML highlighting must not edit buffer text")

local template_lines = { "{% if visible %}" }
vim.list_extend(template_lines, lines)
template_lines[#template_lines + 1] = "{% endif %}"
local template = buffer("htmldjango", template_lines)
check_tags(template, 1)
assert(vim.deep_equal(api.nvim_buf_get_lines(template, 0, -1, false), template_lines),
  "template highlighting must not edit buffer text")

local query_get = vim.treesitter.query.get
vim.treesitter.query.get = function(language, kind)
  if language == "html" and kind == "highlights" then return nil end
  return query_get(language, kind)
end
assert(not treesitter.configure_html_highlights(),
  "an unavailable HTML query must not interrupt editing")
vim.treesitter.query.get = query_get

print("Deep HTML highlighting tests passed")
