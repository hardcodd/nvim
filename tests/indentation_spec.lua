vim.opt.rtp:prepend(vim.fn.getcwd())
vim.cmd("filetype plugin on")
require("autocmds")
vim.cmd("runtime plugin/editorconfig.lua")

local function assert_indent(buf, width, spaces, label)
  local options = vim.bo[buf]
  assert(options.shiftwidth == width, label .. " shiftwidth")
  assert(options.tabstop == width, label .. " tabstop")
  assert(options.softtabstop == (spaces and -1 or 0), label .. " softtabstop")
  assert(options.expandtab == spaces, label .. " expandtab")
end

local function open_file(path, filetype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf, path)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = filetype
  return buf
end

local two_space = {
  "html", "htmldjango", "css", "scss", "javascript", "javascriptreact", "typescript",
  "typescriptreact", "json", "jsonc", "yaml", "xml", "vue", "svelte",
  "markdown", "toml", "lua",
}
for _, filetype in ipairs(two_space) do
  local buf = open_file(vim.fn.tempname() .. ".test", filetype)
  assert_indent(buf, 2, true, filetype)
end

local four_space = { "python", "c", "cpp", "cs", "java", "rust", "sh", "text" }
for _, filetype in ipairs(four_space) do
  local buf = open_file(vim.fn.tempname() .. ".test", filetype)
  assert_indent(buf, 4, true, filetype)
end

for _, case in ipairs({ { "go", 8 }, { "make", 8 } }) do
  local buf = open_file(vim.fn.tempname() .. ".test", case[1])
  assert_indent(buf, case[2], false, case[1])
end

local python = open_file(vim.fn.tempname() .. ".py", "python")
vim.api.nvim_buf_set_lines(python, 0, -1, false, { "" })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i<Tab><Esc>", true, false, true), "xt", false)
assert(vim.api.nvim_buf_get_lines(python, 0, 1, false)[1] == "    ",
  "Python Tab input must insert four spaces")
local javascript = open_file(vim.fn.tempname() .. ".js", "javascript")
vim.api.nvim_buf_set_lines(javascript, 0, -1, false, { "" })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i<Tab><Esc>", true, false, true), "xt", false)
assert(vim.api.nvim_buf_get_lines(javascript, 0, 1, false)[1] == "  ",
  "JavaScript Tab input must insert two spaces")
local go = open_file(vim.fn.tempname() .. ".go", "go")
vim.api.nvim_buf_set_lines(go, 0, -1, false, { "" })
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i<Tab><Esc>", true, false, true), "xt", false)
assert(vim.api.nvim_buf_get_lines(go, 0, 1, false)[1] == "\t",
  "Go Tab input must insert a tab character")

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
vim.fn.writefile({
  "root = true", "[*]", "indent_style = space", "indent_size = 6",
  "[*.go]", "indent_style = tab", "tab_width = 3", "indent_size = 3",
}, root .. "/.editorconfig")
vim.fn.writefile({ "" }, root .. "/override.js")
vim.fn.writefile({ "" }, root .. "/override.go")
vim.cmd.edit(vim.fn.fnameescape(root .. "/override.js"))
assert_indent(vim.api.nvim_get_current_buf(), 6, true, "JavaScript EditorConfig override")
vim.cmd.edit(vim.fn.fnameescape(root .. "/override.go"))
assert(vim.bo.shiftwidth == 3 and vim.bo.tabstop == 3 and not vim.bo.expandtab,
  "Go EditorConfig must override the tab width")
vim.fn.delete(root, "rf")

print("Indentation defaults passed")
