require("functions.theme").stop()
local lualine = require("lualine")
assert(vim.o.laststatus == 3, "statusline must be global")
local function render(width)
  vim.o.columns = width
  lualine.refresh({ place = { "statusline" }, trigger = "test", force = true })
  return vim.api.nvim_eval_statusline(lualine.statusline(true), { maxwidth = width }).str
end
vim.cmd.enew()
vim.api.nvim_buf_set_name(0, vim.fn.getcwd() .. "/statusline-test.txt")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "alpha beta alpha", "second line" })
vim.bo.filetype = "text"
vim.bo.readonly = true
local namespace = vim.api.nvim_create_namespace("StatuslineTest")
vim.diagnostic.set(namespace, 0, {
  { lnum = 0, col = 0, message = "test error", severity = vim.diagnostic.severity.ERROR },
  { lnum = 1, col = 0, message = "test warning", severity = vim.diagnostic.severity.WARN },
})
vim.wait(100)
local colors = {}
for _, background in ipairs({ "light", "dark", "light" }) do
  vim.o.background = background
  local text = render(120)
  assert(text:find("statusline-test.txt", 1, true), text)
  assert(text:find("[+] [RO]", 1, true), text)
  assert(text:find("E:1", 1, true) and text:find("W:1", 1, true), text)
  assert(text:find("◣", 1, true) and text:find("◢", 1, true), "diagonal joins missing")
  assert(vim.trim(text):sub(1, 6) == "NORMAL", "left outside edge must be straight")
  assert(vim.trim(text):sub(-3) == "1:1", "right outside edge must be straight")
  colors[background] = vim.api.nvim_get_hl(0, { name = "lualine_a_normal", link = false }).bg
end
assert(colors.light ~= colors.dark, "statusline palette must follow theme")
vim.bo.fileencoding = "latin1"
assert(render(120):find("latin1", 1, true), "file encoding missing")
vim.bo.fileencoding = ""
assert(render(120):find(vim.o.encoding, 1, true), "encoding fallback missing")
vim.bo.fileencoding = "utf-8"
vim.bo.bomb = true
assert(render(120):find("[BOM]", 1, true), "BOM indicator missing")
vim.bo.bomb = false
for _, width in ipairs({ 120, 90, 70, 50 }) do
  local text = render(width)
  assert(vim.fn.strdisplaywidth(text) <= width, text)
  assert(text:find("[RO]", 1, true) and text:find("[+]", 1, true), text)
  if width < 80 then assert(not text:find("text", 1, true), text) end
  print(width, text)
end
vim.o.columns = 120
vim.fn.setreg("/", "alpha")
vim.o.hlsearch = true
vim.v.hlsearch = 1
assert(render(120):find("/2]", 1, true), "search count missing")
vim.cmd.nohlsearch()
assert(not render(120):find("/2]", 1, true))
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.cmd.normal({ "vll", bang = true })
assert(render(120):find(" 3 ", 1, true), "selection size missing")
vim.cmd.normal({ vim.api.nvim_replace_termcodes("<Esc>", true, false, true), bang = true })
local get_clients = vim.lsp.get_clients
vim.lsp.get_clients = function() return { { id = 999, name = "test-lsp" } } end
assert(render(120):find("test-lsp", 1, true), "attached LSP missing")
assert(not render(90):find("test-lsp", 1, true), "LSP must hide in narrow views")
vim.lsp.get_clients = get_clients
assert(not render(120):find("test-lsp", 1, true))
vim.cmd.vsplit()
assert(vim.o.laststatus == 3 and render(120):find("statusline-test.txt", 1, true))
vim.cmd.only()
vim.bo.readonly = false
vim.bo.modified = false
vim.diagnostic.reset(namespace)
vim.cmd.enew()
assert(render(120):find("[No Name]", 1, true))
local diff = require("lualine.components.diff.git_diff")
local get_sign_count = diff.get_sign_count
diff.get_sign_count = function() return { added = 2, modified = 3, removed = 1 } end
local with_diff = render(120)
assert(with_diff:find("+2", 1, true) and with_diff:find("~3", 1, true) and with_diff:find("-1", 1, true))
assert(not render(90):find("+2", 1, true))
diff.get_sign_count = get_sign_count
print("statusline integration: passed")
