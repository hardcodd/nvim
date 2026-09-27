vim.opt.rtp:prepend(vim.fn.getcwd())
vim.cmd("filetype plugin on")
require("autocmds")
vim.cmd("runtime plugin/editorconfig.lua")
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/nested/isolated", "p")
vim.fn.writefile({
  "root = true", "[*]", "indent_style = tab", "indent_size = 2",
  "[*.{py,lua}]", "indent_style = space", "indent_size = 4",
  "[explicit.js]", "tab_width = 3",
  "[bad.js]", "tab_width = invalid",
  "[unset.js]", "indent_size = unset",
  "[tab.js]", "indent_size = tab", "tab_width = 6",
  "[direct/*.js]", "tab_width = 3",
}, root .. "/.editorconfig")
vim.fn.writefile({ "[*.js]", "tab_width = 5" }, root .. "/nested/.editorconfig")
vim.fn.writefile({ "root = true", "[*]", "indent_size = 7" }, root .. "/nested/isolated/.editorconfig")
vim.fn.mkdir(root .. "/direct/deep", "p")
local plugins = require("functions.plugins")
local function preview(path, ft)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "\ttext  " })
  plugins.telescope_preview_tabs({ buf = buf, data = { bufname = path, filetype = ft } })
  assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "\ttext  ")
  assert(vim.bo[buf].buftype == "nofile")
  assert(#vim.api.nvim_get_autocmds({ event = "BufWritePre", buffer = buf }) == 0)
  return buf
end
for _, case in ipairs({
  { "plain.js", "javascript", 2 }, { "file.py", "python", 4 },
  { "file.lua", "lua", 4 }, { "explicit.js", "javascript", 3 },
  { "unset.js", "javascript", 2 }, { "tab.js", "javascript", 6 },
  { "nested/file.js", "javascript", 5 },
  { "nested/isolated/file.js", "javascript", 7 },
  { "direct/file.js", "javascript", 3 },
  { "direct/deep/file.js", "javascript", 2 },
}) do
  local path = root .. "/" .. case[1]
  vim.fn.writefile({ "\ttext  " }, path)
  local buf = preview(path, case[2])
  assert(vim.bo[buf].tabstop == case[3], case[1] .. " preview width")
  vim.cmd.edit(vim.fn.fnameescape(path))
  assert(vim.bo.tabstop == case[3], case[1] .. " editor width")
  assert(vim.bo.tabstop == vim.bo[buf].tabstop, "preview/editor mismatch")
  local source = vim.api.nvim_get_current_buf()
  vim.bo[source].tabstop = 9
  local overridden = preview(path, case[2])
  if case[1] ~= "unset.js" then
    assert(vim.bo[overridden].tabstop == case[3], "project width must override source fallback")
  end
  assert(vim.bo[source].tabstop == 9, "preview must not modify the source")
  vim.api.nvim_buf_delete(source, { force = true })
end
local bad = preview(root .. "/bad.js", "javascript")
assert(vim.bo[bad].tabstop == 2, "invalid explicit width must retain fallback")
local no_config = vim.fn.tempname() .. ".js"
assert(vim.bo[preview(no_config, "javascript")].tabstop == 2)
vim.fn.writefile({ "[*.js]", "tab_width = 3" }, root .. "/nested/.editorconfig")
assert(vim.bo[preview(root .. "/nested/file.js", "javascript")].tabstop == 3,
  "changed EditorConfig must be read again")
vim.fn.delete(root, "rf")
print("EditorConfig editor and preview tests passed")
