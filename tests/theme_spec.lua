vim.opt.rtp:prepend(vim.fn.getcwd())
local original_system = vim.system
local original_has = vim.fn.has
local callbacks = {}
local calls = 0
vim.fn.has = function(feature)
  if feature == "macunix" then return 1 end
  return original_has(feature)
end
vim.system = function(command, options, callback)
  assert(command[1] == "/usr/bin/defaults" and command[3] == "-g")
  assert(options.timeout == 2000)
  calls = calls + 1
  callbacks[#callbacks + 1] = callback
  return {}
end
package.loaded.catppuccin = { setup = function(options)
  assert(options.auto_integrations and options.background.light == "latte")
end }
local colorscheme = vim.cmd.colorscheme
vim.cmd.colorscheme = function(name) assert(name == "catppuccin-nvim") end
local theme = require("functions.theme")
local function complete(result)
  table.remove(callbacks, 1)(result)
  vim.wait(20, function() return false end)
end
vim.o.background = "dark"
theme.setup()
assert(calls == 1)
theme.refresh()
assert(calls == 1, "overlapping reads must be skipped")
complete({ code = 0, stdout = "{\n AppleInterfaceStyle = Dark;\n}" })
assert(vim.o.background == "dark")
theme.refresh()
complete({ code = 0, stdout = "{\n AppleLocale = en_US;\n}" })
assert(vim.o.background == "light")
theme.refresh()
complete({ code = 0, stdout = '{\n "AppleInterfaceStyle" = "Dark";\n}' })
assert(vim.o.background == "dark")
for _, result in ipairs({ { code = 1, stdout = "" }, { code = 124 }, { code = 0, stdout = "garbled" } }) do
  theme.refresh()
  complete(result)
  assert(vim.o.background == "dark", "failed reads must preserve appearance")
end
theme.refresh()
theme.setup()
complete({ code = 0, stdout = "{}" })
assert(vim.o.background == "dark", "stale setup callback must be ignored")
complete({ code = 0, stdout = "{}" })
assert(vim.o.background == "light")
assert(#vim.api.nvim_get_autocmds({ group = "SystemAppearance" }) == 2)
local before_tick = calls
assert(vim.wait(3500, function() return calls > before_tick end), "timer must refresh appearance")
complete({ code = 0, stdout = "{}" })
vim.api.nvim_exec_autocmds("FocusGained", {})
assert(#callbacks == 1, "focus must refresh appearance")
theme.stop()
complete({ code = 0, stdout = "{\n AppleInterfaceStyle = Dark;\n}" })
assert(vim.o.background == "light", "shutdown must ignore pending result")
vim.system = function() error("spawn failed") end
theme.setup()
vim.system = function(_, _, callback)
  callbacks[#callbacks + 1] = callback
  return {}
end
theme.refresh()
assert(#callbacks == 1, "spawn failure must allow a retry")
complete({ code = 0, stdout = "{}" })
vim.fn.has = function() return 0 end
local previous_calls = calls
theme.setup()
assert(calls == previous_calls, "other systems must not launch defaults")
theme.stop()
vim.system = original_system
vim.fn.has = original_has
vim.cmd.colorscheme = colorscheme
print("theme_spec: passed")
