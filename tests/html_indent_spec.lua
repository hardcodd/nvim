vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(vim.env.PAIRED_TAGS_SOURCE
  or (vim.fn.stdpath("data") .. "/lazy/paired-tags.nvim"))
vim.cmd("filetype plugin indent on")
require("paired_tags").setup()
require("keymaps")
require("autocmds")
vim.cmd("runtime plugin/editorconfig.lua")

local function enter(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
end

local function open_buffer(filetype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.bo.filetype = filetype
  return buf
end

local function assert_lines(buf, expected, label)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), expected),
    label .. ": " .. vim.inspect(vim.api.nvim_buf_get_lines(buf, 0, -1, false)))
end

for _, filetype in ipairs({ "html", "htmldjango" }) do
  local buf = open_buffer(filetype)
  assert(vim.bo.shiftwidth == 2 and vim.bo.expandtab, filetype .. " defaults")
  assert(vim.bo.indentexpr ~= "", filetype .. " native indent script")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "<div>" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  enter("A<CR>content<Esc>")
  assert_lines(buf, { "<div>", "  content" }, filetype .. " after opening tag")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "<div></div>" })
  vim.api.nvim_win_set_cursor(0, { 1, 5 })
  enter("i<CR>")
  assert_lines(buf, { "<div>", "  ", "</div>" }, filetype .. " single Enter")
  assert(vim.api.nvim_win_get_cursor(0)[1] == 2,
    filetype .. " cursor must stay inside the tag pair")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "<div></div>" })
  vim.api.nvim_win_set_cursor(0, { 1, 5 })
  enter("i<CR>content<Esc>")
  assert_lines(buf, { "<div>", "  content", "</div>" }, filetype .. " matching pair")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false,
    { "<section>", "  <div></div>", "</section>" })
  vim.api.nvim_win_set_cursor(0, { 2, 7 })
  enter("i<CR>content<Esc>")
  assert_lines(buf,
    { "<section>", "  <div>", "    content", "  </div>", "</section>" },
    filetype .. " nested pair")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "<div></span>" })
  vim.api.nvim_win_set_cursor(0, { 1, 5 })
  enter("i<CR><Esc>")
  assert(vim.api.nvim_buf_line_count(buf) == 2,
    filetype .. " nonmatching tags must keep one Enter")
end

local text = open_buffer("text")
vim.api.nvim_buf_set_lines(text, 0, -1, false, { "<div></div>" })
vim.api.nvim_win_set_cursor(0, { 1, 5 })
enter("i<CR><Esc>")
assert(vim.api.nvim_buf_line_count(text) == 2, "non-HTML Enter must be unchanged")

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "root = true", "[*.html]", "indent_style = space", "indent_size = 6" },
  root .. "/.editorconfig")
vim.fn.writefile({ "<div></div>" }, root .. "/override.html")
vim.cmd.edit(vim.fn.fnameescape(root .. "/override.html"))
assert(vim.bo.shiftwidth == 6 and vim.bo.expandtab, "HTML EditorConfig override")
vim.api.nvim_win_set_cursor(0, { 1, 5 })
enter("i<CR>content<Esc>")
assert_lines(vim.api.nvim_get_current_buf(), { "<div>", "      content", "</div>" },
  "HTML Enter must honor EditorConfig")
vim.fn.writefile({ "root = true", "[*.html]", "indent_style = tab",
  "indent_size = 4", "tab_width = 4" }, root .. "/.editorconfig")
vim.fn.writefile({ "<div></div>" }, root .. "/tabs.html")
vim.cmd.edit(vim.fn.fnameescape(root .. "/tabs.html"))
assert(vim.bo.shiftwidth == 4 and not vim.bo.expandtab, "HTML tab EditorConfig override")
vim.api.nvim_win_set_cursor(0, { 1, 5 })
enter("i<CR>content<Esc>")
assert_lines(vim.api.nvim_get_current_buf(), { "<div>", "\tcontent", "</div>" },
  "HTML Enter must honor EditorConfig tabs")
vim.fn.delete(root, "rf")

print("HTML indentation passed")
