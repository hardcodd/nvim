local config_directory = vim.fn.getcwd()
local init_source = table.concat(vim.fn.readfile(config_directory .. "/init.lua"), "\n")
local keymaps_source = table.concat(vim.fn.readfile(config_directory .. "/lua/keymaps.lua"), "\n")
local lazy_source = table.concat(vim.fn.readfile(config_directory .. "/lua/config/lazy.lua"), "\n")
local telescope_source = table.concat(vim.fn.readfile(config_directory .. "/lua/plugins/telescope.lua"), "\n")

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.fn.mkdir(lazy_path .. "/lua/lazy", "p")
vim.fn.writefile({
  "local lazy = {}",
  "function lazy.setup(specifications, options)",
  "  vim.g.test_lazy_specifications = specifications",
  "  vim.g.test_lazy_options = options",
  "end",
  "return lazy",
}, lazy_path .. "/lua/lazy/init.lua")

vim.cmd("set rtp^=" .. vim.fn.fnameescape(config_directory))
dofile(config_directory .. "/init.lua")

local expected_options = {
  number = true,
  relativenumber = true,
  signcolumn = "yes",
  cursorline = true,
  ignorecase = true,
  smartcase = true,
  splitbelow = true,
  splitright = true,
  undofile = true,
  termguicolors = true,
  wrap = false,
}

for option, expected_value in pairs(expected_options) do
  assert(vim.o[option] == expected_value, option .. " was not configured")
end

assert(vim.g.mapleader == " ", "leader key was not configured")
assert(vim.g.editorconfig == true, "native EditorConfig must be enabled")
assert(vim.go.shiftwidth == 4 and vim.go.tabstop == 4
  and vim.go.softtabstop == -1 and vim.go.expandtab,
  "global indentation must default to four spaces")
assert(vim.g.syntax_on ~= nil, "native syntax fallback must be enabled")
assert(init_source:find('require("keymaps")', 1, true), "keymaps module is not loaded")
assert(init_source:find('require("autocmds")', 1, true), "autocmds module is not loaded")
assert(init_source:find('require("config.lazy")', 1, true), "lazy bootstrap is not loaded")
assert(not init_source:find("vim.keymap.set", 1, true), "init.lua must not declare key mappings")
assert(not init_source:find("vim.api.nvim_create_autocmd", 1, true), "init.lua must use the autocmd helper")
assert(not init_source:find("vim.api.nvim_create_augroup", 1, true), "init.lua must use the autocmd helper")
for _, path in ipairs(vim.fn.glob(config_directory .. "/lua/**/*.lua", false, true)) do
  local source = table.concat(vim.fn.readfile(path), "\n")
  if not path:find("/lua/functions/autocmds.lua", 1, true) then
    assert(not source:find("vim.api.nvim_create_autocmd", 1, true), path .. " must use the autocmd helper")
    assert(not source:find("vim.api.nvim_create_augroup", 1, true), path .. " must use the autocmd helper")
  end
  if not path:find("/lua/functions/", 1, true) then
    assert(not source:match("function%s*[%w_.:]*%s*%("), path .. " must not define custom functions")
    assert(not source:find("vim.keymap.set", 1, true), path .. " must use the mapping helper")
  end
end
assert(not init_source:match("function%s*[%w_.:]*%s*%("), "init.lua must use named handlers")
assert(keymaps_source:find("Search", 1, true), "search keymaps block is missing")
assert(keymaps_source:find("Diagnostics", 1, true), "diagnostics keymaps block is missing")
assert(keymaps_source:find("Telescope", 1, true), "Telescope keymaps block is missing")
assert(lazy_source:find("folke/lazy.nvim", 1, true), "lazy.nvim bootstrap source is missing")
assert(telescope_source:find("nvim-telescope/telescope.nvim", 1, true), "Telescope is not declared")
assert(telescope_source:find("nvim-lua/plenary.nvim", 1, true), "Plenary dependency is not declared")
assert(vim.fn.maparg("<Esc>", "n") ~= "", "search-clear mapping is missing")
assert(vim.fn.maparg("[d", "n") ~= "", "previous diagnostic mapping is missing")
assert(vim.fn.maparg("]d", "n") ~= "", "next diagnostic mapping is missing")
assert(vim.fn.maparg("jk", "i") ~= "", "Insert-mode exit mapping is missing")
assert(vim.fn.maparg("<leader>ff", "n") ~= "", "file search mapping is missing")
assert(vim.fn.maparg("<leader>fg", "n") ~= "", "text search mapping is missing")
assert(vim.fn.maparg("<leader>fb", "n") ~= "", "buffer search mapping is missing")
assert(vim.fn.maparg("<leader>fh", "n") ~= "", "help search mapping is missing")
local quit_mapping = vim.fn.maparg("<leader>q", "n"):lower()
local close_buffer_mapping = vim.fn.maparg("<leader>x", "n"):lower()
assert(quit_mapping:find("confirm qall", 1, true), "confirmed quit mapping is missing")
assert(close_buffer_mapping:find("confirm bdelete", 1, true), "confirmed buffer-close mapping is missing")
local save_mapping = vim.fn.maparg("<leader>w", "n"):lower()
assert(save_mapping == "<cmd>write<cr>", "file-save mapping must use plain :write")
local saved_file = vim.fn.tempname() .. ".txt"
vim.fn.writefile({ "before" }, saved_file)
vim.cmd.edit(vim.fn.fnameescape(saved_file))
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "after" })
assert(vim.bo.modified, "test buffer must have unsaved changes")
vim.api.nvim_feedkeys(vim.keycode("<leader>w"), "xt", false)
assert(vim.deep_equal(vim.fn.readfile(saved_file), { "after" }), "save mapping must write the current file")
assert(not vim.bo.modified, "successful save must clear the modified state")
vim.cmd.bdelete()
vim.fn.delete(saved_file)
assert(vim.g.test_lazy_specifications ~= nil, "lazy.nvim setup was not called")
local base_autocmds = vim.api.nvim_get_autocmds({ group = "BaseConfiguration" })
assert(#base_autocmds == 2, "expected autocommands are missing or duplicated")
local indent_autocmds = vim.api.nvim_get_autocmds({ group = "IndentGuides" })
local indent_events = {}
for _, autocmd in ipairs(indent_autocmds) do
  indent_events[autocmd.event] = true
end
for _, event in ipairs({ "BufEnter", "WinEnter", "FileType", "OptionSet" }) do
  assert(indent_events[event], event .. " must refresh indentation guides")
end
local indentation_autocmds = vim.api.nvim_get_autocmds({ group = "IndentationDefaults" })
assert(#indentation_autocmds == 1 and indentation_autocmds[1].event == "FileType"
  and indentation_autocmds[1].pattern == "*", "indentation policy must run on FileType")
local expected_autocmds = {
  TextYankPost = "Highlight copied text",
  BufReadPost = "Restore the last cursor position in normal files",
}
for _, autocmd in ipairs(base_autocmds) do
  assert(expected_autocmds[autocmd.event] == autocmd.desc,
    "base autocommand event or description changed")
  expected_autocmds[autocmd.event] = nil
end
assert(next(expected_autocmds) == nil, "base autocommand is missing")

vim.cmd("new")
assert(not vim.wo.wrap, "new editing windows must not soft-wrap by default")
vim.wo.wrap = true
assert(vim.wo.wrap, "a window must allow an explicit wrap override")
vim.cmd("close")
assert(not vim.wo.wrap, "the override must remain local to its window")
