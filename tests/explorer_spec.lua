vim.g.mapleader = " "
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.cmd("runtime plugin/netrwPlugin.vim")
require("keymaps")

local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/nested directory", "p")
root = assert(vim.uv.fs_realpath(root))
vim.fn.writefile({ "original" }, root .. "/nested directory/sample.txt")
vim.cmd.cd(vim.fn.fnameescape(root))

local function explore()
  vim.api.nvim_feedkeys(" e", "xt", false)
  assert(vim.bo.filetype == "netrw", "leader e must open the file browser")
end

explore()
assert(vim.b.netrw_curdir == root, "unnamed buffer must browse the working directory")
local initial_browser = vim.api.nvim_get_current_buf()
vim.cmd.enew()
vim.api.nvim_buf_delete(initial_browser, { force = true })
vim.cmd.edit(vim.fn.fnameescape(root .. "/nested directory/sample.txt"))
local source = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(source, 0, -1, false, { "unsaved change" })
explore()
assert(vim.b.netrw_curdir == root .. "/nested directory", "browser must show the current file directory")
assert(vim.api.nvim_buf_is_valid(source) and vim.bo[source].modified, "unsaved buffer must be preserved")
assert(vim.api.nvim_buf_get_lines(source, 0, 1, false)[1] == "unsaved change", "unsaved contents must remain intact")
local browser = vim.api.nvim_get_current_buf()
local browser_window = vim.api.nvim_get_current_win()
local cursor = vim.api.nvim_win_get_cursor(browser_window)
vim.cmd.vsplit()
vim.api.nvim_win_set_buf(0, source)
local windows = #vim.api.nvim_list_wins()
explore()
assert(vim.api.nvim_get_current_win() == browser_window, "visible browser must be focused")
assert(#vim.api.nvim_list_wins() == windows, "visible browser must not create a window")
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor), "browser cursor must be preserved")
explore()
assert(vim.api.nvim_get_current_buf() == browser, "repeated presses must reuse the browser")
vim.cmd.tabnew()
explore()
assert(vim.api.nvim_get_current_win() == browser_window, "browser in another tab must be focused")
vim.api.nvim_win_set_buf(browser_window, source)
vim.bo[source].modified = true
vim.o.hidden = false
explore()
assert(vim.api.nvim_get_current_buf() == browser, "hidden browser buffer must be reused")
assert(vim.bo[source].modified, "hidden browser reuse must preserve unsaved changes")
local browser_count = 0
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buf].filetype == "netrw" then browser_count = browser_count + 1 end
end
assert(browser_count == 1, "only one browser buffer may exist")
assert(vim.fn.maparg("<leader>e", "i") == "", "mapping must only apply in Normal mode")
vim.fn.delete(root, "rf")
print("Explorer behavior tests passed")
