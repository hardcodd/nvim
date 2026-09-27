vim.opt.rtp:prepend(vim.fn.getcwd())
local auto = require("functions.autocmds")

local group = auto.group("AutocmdHelperTest")
local calls = 0
local options = { group = group, pattern = "AutocmdHelperTarget", once = true,
  desc = "Ignored description", callback = function() error("Ignored callback") end }
local original = vim.deepcopy(options)
local id = auto.set("User", function() calls = calls + 1 end, "Run test callback", options)
assert(vim.deep_equal(options, original), "caller options must not change")
local registered = vim.api.nvim_get_autocmds({ group = group })
assert(#registered == 1 and registered[1].id == id)
assert(registered[1].desc == "Run test callback" and registered[1].once)
vim.api.nvim_exec_autocmds("User", { pattern = "OtherTarget" })
assert(calls == 0, "pattern must limit the autocommand")
vim.api.nvim_exec_autocmds("User", { pattern = "AutocmdHelperTarget" })
vim.api.nvim_exec_autocmds("User", { pattern = "AutocmdHelperTarget" })
assert(calls == 1, "callback must run once")

local multiple = 0
auto.set({ "BufEnter", "BufLeave" }, function() multiple = multiple + 1 end,
  "Handle both buffer events", { group = group })
local events = vim.api.nvim_get_autocmds({ group = group })
assert(#events == 2, "both events must be registered")
vim.api.nvim_exec_autocmds("BufEnter", {})
vim.api.nvim_exec_autocmds("BufLeave", {})
assert(multiple == 2, "both events must dispatch")

local replacement = auto.group("AutocmdHelperTest")
assert(replacement == group and #vim.api.nvim_get_autocmds({ group = group }) == 0,
  "creating a group again must replace its autocommands")

assert(not pcall(auto.group, " "))
assert(not pcall(auto.set, "User", function() end, " "))
assert(not pcall(auto.set, "User", "echo ignored", "Invalid callback"))
assert(not pcall(auto.set, "", function() end, "Invalid event"))
assert(not pcall(auto.set, {}, function() end, "Invalid event list"))
assert(#vim.api.nvim_get_autocmds({ group = group }) == 0,
  "invalid registrations must not create autocommands")
print("Autocommand helper tests passed")
