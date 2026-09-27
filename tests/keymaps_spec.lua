vim.opt.rtp:prepend(vim.fn.getcwd())
local map = require("functions.keymaps")
local calls = 0
map.n("<F6>", function() calls = calls + 1 end, "Run callback")
vim.api.nvim_feedkeys(vim.keycode("<F6>"), "xt", false)
assert(calls == 1, "mapping must invoke the callback")
local entry = vim.fn.maparg("<F6>", "n", false, true)
assert(entry.desc == "Run callback" and entry.silent == 1 and entry.noremap == 1)

map.n("<F7>", map.cmd("let g:keymap_command_test = 1"), "Run command")
vim.api.nvim_feedkeys(vim.keycode("<F7>"), "xt", false)
assert(vim.g.keymap_command_test == 1, "command must execute")
map.i("jk", "<Esc>", "Leave Insert mode")
assert(vim.fn.maparg("jk", "i") == "<Esc>")

local options = { silent = false, remap = true, nowait = true }
local original = vim.deepcopy(options)
map.set({ "n", "x" }, "<F8>", "<F6>", "Multiple modes", options)
for _, mode in ipairs({ "n", "x" }) do
  entry = vim.fn.maparg("<F8>", mode, false, true)
  assert(entry.silent == 0 and entry.noremap == 0 and entry.nowait == 1)
end
assert(vim.deep_equal(options, original), "caller options must not be changed")
map.n("<F9>", "<Nop>", "Buffer mapping", { buf = 0 })
assert(vim.fn.maparg("<F9>", "n", false, true).buffer == 1)
vim.cmd.enew()
assert(vim.fn.maparg("<F9>", "n") == "", "buffer mapping must not leak")

for _, mode in ipairs({ "n", "i", "v", "x", "s", "o", "c", "t" }) do
  map[mode]("<F10>", "<Nop>", "Mode helper")
  assert(vim.fn.maparg("<F10>", mode) ~= "", "missing mode helper: " .. mode)
end
assert(not pcall(map.n, "", "<Nop>", "Empty keys"))
assert(not pcall(map.n, "<F11>", "<Nop>", " "))
assert(not pcall(map.n, "<F11>", 42, "Invalid action"))
assert(not pcall(map.cmd, ""))
assert(not pcall(map.cmd, "echo 1\necho 2"))
assert(vim.fn.maparg("<F11>", "n") == "", "invalid mapping must not be registered")
print("Keymap helper tests passed")
