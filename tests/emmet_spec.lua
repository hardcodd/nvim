vim.opt.rtp:prepend(vim.fn.getcwd())
local emmet = require("functions.emmet")
local original_clients = vim.lsp.get_clients
local original_active = vim.snippet.active
local original_pum = vim.fn.pumvisible
local original_info = vim.fn.complete_info
local client = { id = 23, offset_encoding = "utf-16" }
vim.lsp.get_clients = function() return { client } end
vim.snippet.active = function() return false end
vim.fn.pumvisible = function() return 0 end

vim.api.nvim_buf_set_lines(0, 0, -1, false, { "    " })
vim.api.nvim_win_set_cursor(0, { 1, 3 })
assert(emmet.tab() == "<Tab>", "whitespace keeps ordinary Tab")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "div" })
vim.api.nvim_win_set_cursor(0, { 1, 2 })
assert(emmet.tab():find("expand", 1, true), "abbreviation requests Emmet")
vim.lsp.get_clients = function() return {} end
assert(emmet.tab() == "<Tab>", "unsupported buffers keep ordinary Tab")
vim.snippet.active = function() return true end
assert(emmet.tab():find("jump(1)", 1, true), "Tab advances snippet fields")
assert(emmet.backtab():find("jump(-1)", 1, true), "Shift-Tab returns to the previous field")
assert(not emmet.backtab():find("<C-e>", 1, true), "without a popup Ctrl-E would insert a character")
vim.fn.pumvisible = function() return 1 end
vim.fn.complete_info = function() return { selected = 0 } end
assert(emmet.tab() == "<C-y>", "selected completion takes priority")
vim.snippet.active = function() return false end
assert(emmet.backtab() == "<S-Tab>", "no backwards field retains native behavior")

vim.lsp.get_clients = original_clients
vim.snippet.active = original_active
vim.fn.pumvisible = original_pum
vim.fn.complete_info = original_info
local config = dofile("after/lsp/emmet_language_server.lua")
for _, ft in ipairs({ "html", "htmldjango", "javascriptreact", "typescriptreact", "vue", "css" }) do
  assert(vim.list_contains(config.filetypes, ft), "missing Emmet language: " .. ft)
end
assert(not vim.list_contains(config.filetypes, "javascript"), "ordinary JavaScript is not markup")
assert(vim.list_contains(require("config.lsp").servers, "emmet_language_server"), "Mason must enable Emmet")
print("Emmet key dispatch checks passed")
