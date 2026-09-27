vim.opt.rtp:prepend(vim.fn.getcwd())
local captured
package.loaded.lualine = { setup = function(options) captured = options end }
local statusline = require("functions.statusline")
statusline.setup()
assert(captured.options.globalstatus and not captured.options.icons_enabled)
local original_columns = vim.o.columns
vim.o.columns = 120
assert(statusline.wide() and statusline.medium() and statusline.context())
vim.o.columns = 90
assert(not statusline.wide() and statusline.medium())
vim.o.columns = 70
assert(not statusline.medium() and statusline.context())
vim.o.columns = 50
assert(not statusline.context() and statusline.mode("NORMAL") == "N")
vim.o.columns = 120
assert(statusline.mode("INSERT") == "INSERT")
vim.cmd.enew()
assert(statusline.filename() == "[No Name]")
vim.bo.modified = true
vim.bo.readonly = true
assert(statusline.filename():find("[+] [RO]", 1, true))
vim.bo.modified = false
vim.bo.readonly = false
local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/.git", "p")
vim.fn.mkdir(directory .. "/src", "p")
vim.api.nvim_buf_set_name(0, directory .. "/src/100%file.lua")
statusline.update_root()
assert(statusline.filename() == "src/100%%file.lua", "project path must escape statusline directives")
vim.o.columns = 50
assert(statusline.filename() == "100%%file.lua")
vim.api.nvim_buf_set_name(0, directory .. "/src/" .. string.rep("x", 150) .. ".lua")
assert(vim.fn.strdisplaywidth(statusline.filename()) <= 20, "long names must fit")
vim.bo.modified = true
vim.bo.readonly = true
assert(statusline.filename():find("[+] [RO]", 1, true), "shortening must retain state")
vim.bo.modified = false
vim.bo.readonly = false
vim.cmd.enew()
vim.o.columns = original_columns
vim.fn.delete(directory, "rf")
print("statusline behavior: passed")
