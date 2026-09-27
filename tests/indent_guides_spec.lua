vim.opt.rtp:prepend(vim.fn.getcwd())
local editor = require("functions.editor")

local function warning_positions(line)
  local positions = {}
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == "IndentWarning" then
      local result = vim.fn.matchstrpos(line, match.pattern)
      if result[2] >= 0 then
        positions[#positions + 1] = { result[2], result[3] }
      end
    end
  end
  return positions
end

local function assert_warning(line, column)
  local positions = warning_positions(line)
  assert(#positions == 1 and positions[1][1] == column
    and positions[1][2] == column + 1,
    "wrong mixed-indent warning for " .. vim.inspect(line))
end

local function assert_rendered(row, expected)
  local cells = {}
  for column = 1, vim.fn.strdisplaywidth(expected) do
    cells[#cells + 1] = vim.fn.screenstring(row, column)
  end
  assert(table.concat(cells) == expected,
    "incorrect indentation on row " .. row .. ": " .. vim.inspect(cells))
end

vim.bo.shiftwidth = 2
editor.update_indent_guides()
assert(vim.wo.list, "normal buffers must show leading tab guides")
local chars = vim.opt_local.listchars:get()
assert(chars.tab == "  " and chars.leadtab == "│ ",
  "leading tabs must use the narrow guide")
assert(chars.lead == nil and chars.leadmultispace == nil,
  "native list characters must not mark spaces")
for _, line in ipairs({ " x", "  x", "   x", "    x", "  x y", "x y", "\tx", "   " }) do
  assert(#warning_positions(line) == 0, "space guides must not be warnings")
end
assert_warning(" \tx", 1)
assert_warning("\t x", 1)

vim.bo.buftype = "nofile"
editor.update_indent_guides()
assert(not vim.wo.list, "special buffers must hide tab guides")
assert(#warning_positions(" \tx") == 0, "special buffers must hide mixed-indent warnings")
vim.bo.buftype = ""
editor.update_indent_guides()
assert(vim.wo.list, "normal buffers must restore guides")

vim.bo.filetype = "lua"
vim.bo.shiftwidth = 8
vim.bo.tabstop = 8
vim.bo.softtabstop = 0
vim.bo.expandtab = false
local preloaded_lua_buffer = vim.api.nvim_create_buf(true, false)
vim.bo[preloaded_lua_buffer].filetype = "lua"
vim.bo[preloaded_lua_buffer].shiftwidth = 8
vim.bo[preloaded_lua_buffer].tabstop = 8
vim.bo[preloaded_lua_buffer].softtabstop = 0
vim.bo[preloaded_lua_buffer].expandtab = false
local preloaded_css_buffer = vim.api.nvim_create_buf(true, false)
vim.bo[preloaded_css_buffer].filetype = "css"
local preloaded_go_buffer = vim.api.nvim_create_buf(true, false)
vim.bo[preloaded_go_buffer].filetype = "go"
dofile(vim.fn.getcwd() .. "/lua/autocmds.lua")
for _, buf in ipairs({ vim.api.nvim_get_current_buf(), preloaded_lua_buffer }) do
  assert(vim.bo[buf].shiftwidth == 2 and vim.bo[buf].tabstop == 2
    and vim.bo[buf].softtabstop == -1 and vim.bo[buf].expandtab,
    "preloaded Lua buffers must use two-space indentation")
end
assert(vim.bo[preloaded_css_buffer].shiftwidth == 2
  and vim.bo[preloaded_css_buffer].tabstop == 2
  and vim.bo[preloaded_css_buffer].expandtab,
  "preloaded CSS buffers must use two-space indentation")
assert(vim.bo[preloaded_go_buffer].shiftwidth == 8
  and vim.bo[preloaded_go_buffer].tabstop == 8
  and not vim.bo[preloaded_go_buffer].expandtab,
  "preloaded Go buffers must retain tabs")

vim.cmd("new")
vim.bo.shiftwidth = 4
assert(vim.wo.list, "new editing windows must show guides")
vim.cmd("wincmd p")
assert(vim.wo.list and vim.bo.shiftwidth == 2,
  "returning to a buffer must keep its indent width")
vim.cmd("wincmd p")
assert(vim.wo.list and vim.bo.shiftwidth == 4,
  "switching windows must restore their guides")

vim.cmd("only")
vim.bo.shiftwidth = 2
vim.bo.tabstop = 4
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.signcolumn = "no"
vim.o.termguicolors = true
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#556677" })
vim.api.nvim_set_hl(0, "IndentRemainder", { fg = "#8899aa" })
vim.api.nvim_set_hl(0, "IndentWarning", { bg = "#334455" })
local lines = { " x", "  x", "   x", "    x", "\tx", " \tx", "x y", "   " }
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.cmd.redraw()
for row, expected in ipairs({ "·x", "│ x", "│ ·x", "│ │ x", "│   x", " │  x", "x y" }) do
  assert_rendered(row, expected)
end
assert_rendered(8, "   ")
assert(vim.fn.screenattr(3, 1) ~= vim.fn.screenattr(3, 3),
  "complete-level guides and incomplete-level dots must have distinct colors")
assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[3] == "   x",
  "visual guides must not modify file contents")
local guide_namespace = vim.api.nvim_get_namespaces().IndentGuides
assert(#vim.api.nvim_buf_get_extmarks(0, guide_namespace, 0, -1, {}) == 0,
  "redraw guides must not leave persistent marks")
assert(vim.fn.screenattr(6, 2) ~= vim.fn.screenattr(6, 1),
  "mixed indentation must still be highlighted")

vim.api.nvim_buf_set_lines(0, 0, 1, false, { "    x" })
vim.cmd.redraw()
assert_rendered(1, "│ │ x")

vim.bo.shiftwidth = 4
vim.cmd.redraw()
assert_rendered(1, "│   x")
assert_rendered(3, "···x")

vim.bo.shiftwidth = 0
vim.bo.tabstop = 3
vim.cmd.redraw()
assert_rendered(2, "··x")
assert_rendered(3, "│  x")

vim.bo.shiftwidth = 1
vim.cmd.redraw()
assert_rendered(2, "││x")

vim.bo.buftype = "nofile"
editor.update_indent_guides()
vim.cmd.redraw()
assert_rendered(2, "  x")

local lua_buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(lua_buffer)
vim.bo.filetype = "lua"
assert(vim.bo.shiftwidth == 2 and vim.bo.tabstop == 2
  and vim.bo.softtabstop == -1 and vim.bo.expandtab,
  "later Lua buffers must use two-space indentation")
local other_buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(other_buffer)
vim.bo.filetype = "text"
assert(vim.bo.shiftwidth == 4 and vim.bo.tabstop == 4
  and vim.bo.softtabstop == -1 and vim.bo.expandtab,
  "other buffers must use four-space defaults")

print("indent_guides_spec: passed")
