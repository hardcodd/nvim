vim.opt.rtp:prepend(vim.fn.getcwd())
local data = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.rtp:append(data .. "plenary.nvim")
vim.opt.rtp:append(data .. "telescope.nvim")
require("functions.plugins").telescope()
require("functions.plugins").telescope()
assert(#vim.api.nvim_get_autocmds({ group = "TelescopePreviewTabs" }) == 1)
require("autocmds")
vim.cmd("filetype plugin on")
assert(require("telescope.config").values.layout_config.scroll_speed == 2)

local mappings = require("telescope.config").values.mappings
local expected = {
  ["<C-j>"] = "move_selection_next",
  ["<C-k>"] = "move_selection_previous",
  ["<C-S-j>"] = "preview_scrolling_down",
  ["<C-S-k>"] = "preview_scrolling_up",
  ["<C-S-h>"] = "preview_scrolling_left",
  ["<C-S-l>"] = "preview_scrolling_right",
}
for _, mode in ipairs({ "i", "n" }) do
  for key, action in pairs(expected) do
    assert(mappings[mode] and mappings[mode][key] == action, mode .. " " .. key)
    if mode == "i" then
      assert(vim.fn.maparg(key, mode) ~= "", "Insert navigation mapping is missing: " .. key)
    else
      assert(vim.fn.maparg(key, mode) == "", "Telescope Normal-mode keys must not be global")
    end
  end
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
pickers.new({}, {
  finder = finders.new_table({ "first", "second", "third" }),
  initial_mode = "normal",
  sorting_strategy = "ascending",
}):find()
assert(vim.wait(1000, function()
  local picker = require("telescope.actions.state").get_current_picker(vim.api.nvim_get_current_buf())
  return picker:get_selection() ~= nil
end))
local buffer = vim.api.nvim_get_current_buf()
local picker = require("telescope.actions.state").get_current_picker(buffer)
for _, mode in ipairs({ "i", "n" }) do
  for key in pairs(expected) do
    local entry = vim.fn.maparg(key, mode, false, true)
    assert(entry.buffer == 1 and type(entry.callback) == "function", mode .. " " .. key)
  end
  assert(vim.fn.maparg("<CR>", mode) ~= "", "default selection mapping must remain")
  local before = picker:get_selection().index
  vim.fn.maparg("<C-j>", mode, false, true).callback()
  assert(picker:get_selection().index == before + 1)
  vim.fn.maparg("<C-k>", mode, false, true).callback()
  assert(picker:get_selection().index == before)
  vim.fn.maparg("<C-S-j>", mode, false, true).callback()
  vim.fn.maparg("<C-S-k>", mode, false, true).callback()
  vim.fn.maparg("<C-S-h>", mode, false, true).callback()
  vim.fn.maparg("<C-S-l>", mode, false, true).callback()
end
require("telescope.actions").close(buffer)

local function preview_tabs(filename, filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_call(buf, function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = "TelescopePreviewerLoaded",
      data = { bufname = filename, filetype = filetype },
    })
  end)
  return buf
end
local lua_preview = preview_tabs("/tmp/unopened-telescope-test.lua", "lua")
assert(vim.bo[lua_preview].tabstop == 2, "Lua preview must follow the editor FileType policy")
assert(vim.bo[lua_preview].buftype == "nofile")
local text_preview = preview_tabs("/tmp/unopened-telescope-test.txt", "text")
assert(vim.bo[text_preview].tabstop == 4)
local source = vim.api.nvim_create_buf(true, false)
local source_path = vim.fn.tempname() .. ".lua"
vim.api.nvim_buf_set_name(source, source_path)
vim.bo[source].tabstop = 5
vim.bo[source].vartabstop = "3,5"
vim.api.nvim_buf_set_lines(source, 0, -1, false, { "\tunchanged" })
local loaded_preview = preview_tabs(source_path, "lua")
assert(vim.bo[loaded_preview].tabstop == 5)
assert(vim.bo[loaded_preview].vartabstop == "3,5")
assert(vim.bo[source].tabstop == 5 and vim.bo[source].vartabstop == "3,5")
assert(vim.api.nvim_buf_get_lines(source, 0, -1, false)[1] == "\tunchanged")
local unknown_preview = preview_tabs(nil, nil)
assert(vim.bo[unknown_preview].tabstop == vim.go.tabstop)
assert(vim.bo[unknown_preview].vartabstop == vim.go.vartabstop)

local previewers = require("telescope.previewers")
vim.o.columns = 160
vim.o.lines = 50
pickers.new({}, {
  finder = finders.new_table({ "long lines" }),
  initial_mode = "normal",
  previewer = previewers.new_buffer_previewer({
    get_buffer_by_name = function() return "/tmp/unopened-telescope-test.lua" end,
    define_preview = function(self)
      local lines = {}
      for i = 1, 100 do lines[i] = string.rep("x", 200) end
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    end,
  }),
}):find()
assert(vim.wait(1000, function()
  local current = require("telescope.actions.state").get_current_picker(vim.api.nvim_get_current_buf())
  return current.previewer.state and current.previewer.state.winid ~= nil
end))
buffer = vim.api.nvim_get_current_buf()
picker = require("telescope.actions.state").get_current_picker(buffer)
local win = picker.previewer.state.winid
assert(vim.wait(1000, function()
  return vim.bo[picker.previewer.state.bufnr].tabstop == 2
end), "real preview event must apply Lua tab widths")
vim.wo[win].scrolloff = 0
vim.wo[win].sidescrolloff = 0
for _, mode in ipairs({ "i", "n" }) do
  local function view()
    return vim.api.nvim_win_call(win, vim.fn.winsaveview)
  end
  local before = view()
  vim.fn.maparg("<C-S-l>", mode, false, true).callback()
  assert(view().leftcol == before.leftcol + 2, "horizontal step must be two columns")
  vim.fn.maparg("<C-S-h>", mode, false, true).callback()
  assert(view().leftcol == before.leftcol)
  vim.fn.maparg("<C-S-j>", mode, false, true).callback()
  assert(view().topline == before.topline + 2, "vertical step must be two lines")
  vim.fn.maparg("<C-S-k>", mode, false, true).callback()
  assert(view().topline == before.topline)
end
require("telescope.actions").close(buffer)
print("Telescope mapping tests passed")
