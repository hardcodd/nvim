local function type_keys(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), "xt", false)
end

local function new_buffer(filetype, lines)
  vim.cmd.enew()
  vim.bo.filetype = filetype
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  return vim.api.nvim_get_current_buf()
end

assert(type(require("Comment").setup) == "function")
assert(type(require("ts_context_commentstring").calculate_commentstring) == "function")
assert(type(require("todo-comments").setup) == "function")

for _, mapping in ipairs({ { "gcc", "n" }, { "gc", "n" }, { "gc", "x" },
  { "gbc", "n" }, { "gb", "n" }, { "gb", "x" } }) do
  assert(vim.fn.maparg(mapping[1], mapping[2]) ~= "",
    "missing comment mapping " .. mapping[1] .. " in " .. mapping[2])
end

new_buffer("lua", { "local value = 1", "local other = 2" })
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "-- local value = 1", "gcc must comment a line")
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "local value = 1", "gcc must uncomment a line")
type_keys("gcj")
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, 2, false),
  { "-- local value = 1", "-- local other = 2" }), "gc motion must comment a range")
type_keys("Vjgc")
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, 2, false),
  { "local value = 1", "local other = 2" }), "Visual gc must uncomment the selection")

new_buffer("css", { "body { color: red; }" })
type_keys("gbc")
assert(vim.api.nvim_get_current_line():find("/*", 1, true) ~= nil,
  "gbc must add block comment delimiters")
type_keys("gbc")
assert(vim.api.nvim_get_current_line() == "body { color: red; }",
  "gbc must remove block comment delimiters")

new_buffer("typescriptreact", {
  "const App = () => (",
  "  <div>",
  "    <span>Hello</span>",
  "  </div>",
  ");",
})
vim.treesitter.start(0)
vim.treesitter.get_parser(0):parse()
vim.api.nvim_win_set_cursor(0, { 3, 5 })
assert(require("ts_context_commentstring").calculate_commentstring() == "{/* %s */}",
  "JSX elements must use JSX comment syntax")
type_keys("gcc")
assert(vim.api.nvim_get_current_line():find("{/*", 1, true) ~= nil,
  "gcc must use JSX context rather than a JavaScript line comment")

new_buffer("vue", {
  "<template>",
  "  <div>Hello</div>",
  "</template>",
  "<script>",
  "const answer = 1",
  "</script>",
  "<style>",
  "body { color: red; }",
  "</style>",
})
vim.treesitter.start(0)
vim.treesitter.get_parser(0):parse()
local context = require("ts_context_commentstring")
assert(context.calculate_commentstring({ location = { 1, 4 } }) == "<!-- %s -->",
  "Vue template must use HTML comments")
vim.api.nvim_win_set_cursor(0, { 4, 0 })
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "<!-- <script> -->",
  "Vue script tag must use HTML comments")
type_keys("gcc")
vim.api.nvim_win_set_cursor(0, { 5, 0 })
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "// const answer = 1",
  "gcc must use JavaScript comments in a Vue script")
vim.api.nvim_win_set_cursor(0, { 8, 0 })
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "/* body { color: red; } */",
  "gcc must use CSS comments in a Vue style")
vim.api.nvim_win_set_cursor(0, { 7, 0 })
type_keys("gcc")
assert(vim.api.nvim_get_current_line() == "<!-- <style> -->",
  "Vue style tag must use HTML comments")

local todo_buf = new_buffer("lua", { "-- TODO: inspect this", "local text = 'FIXME: plain string'", "-- FIXME: repair" })
vim.treesitter.start(todo_buf)
vim.treesitter.get_parser(todo_buf):parse()
local todo_config = require("todo-comments.config")
assert(vim.wait(1000, function() return todo_config.loaded end), "TODO plugin did not initialize")
assert(todo_config.loaded and todo_config.options.highlight.comments_only)
require("todo-comments.highlight").highlight(todo_buf, 0, 2)
local marks = vim.api.nvim_buf_get_extmarks(todo_buf, todo_config.ns, 0, -1, {})
local marked_rows = {}
for _, mark in ipairs(marks) do
  marked_rows[mark[2]] = true
end
assert(marked_rows[0] and marked_rows[2], "TODO and FIXME comments must be highlighted")
assert(not marked_rows[1], "a string containing FIXME must not be highlighted")

local template_buf = new_buffer("htmldjango", {
  "<div>TODO: plain text</div>",
  "<!-- TODO: rename -->",
  "{% with name='FIXME: plain string' %}",
  "<!-- FIXME: repair -->",
})
vim.treesitter.start(template_buf)
vim.treesitter.get_parser(template_buf):parse()
assert(#vim.treesitter.get_captures_at_pos(template_buf, 1, 5) == 0,
  "template regression must start before HTML injection highlights are parsed")
require("todo-comments.highlight").highlight(template_buf, 0, 3)
local template_marks = vim.api.nvim_buf_get_extmarks(template_buf, todo_config.ns, 0, -1,
  { details = true })
local template_rows = {}
for _, mark in ipairs(template_marks) do
  if mark[4].hl_group == "TodoBgTODO" or mark[4].hl_group == "TodoBgFIX" then
    template_rows[mark[2]] = true
  end
end
assert(template_rows[1] and template_rows[3],
  "TODO and FIXME must be highlighted in htmldjango HTML comments")
assert(not template_rows[0] and not template_rows[2],
  "plain template text and strings must not receive TODO labels")

assert(todo_config.options.signs == false, "TODO signs must not require Nerd Font glyphs")
assert(vim.fn.exists(":TodoTelescope") == 2, "TODO Telescope command must be available")
assert(vim.fn.maparg("<leader>ft", "n") ~= "", "TODO search mapping must exist")

local search_root = vim.fn.tempname()
assert(vim.fn.mkdir(search_root, "p") == 1)
assert(vim.fn.writefile({ "-- TODO: searchable item" }, search_root .. "/sample.lua") == 0)
local results
require("todo-comments.search").search(function(found) results = found end, { cwd = search_root })
assert(vim.wait(3000, function() return results ~= nil end), "TODO search timed out")
assert(#results == 1 and results[1].text:find("TODO: searchable item", 1, true) ~= nil,
  "TODO project search must return the matching comment")
vim.fn.delete(search_root, "rf")

local function luminance(color)
  local hex = string.format("%06x", color)
  local function channel(start)
    local value = tonumber(hex:sub(start, start + 1), 16) / 255
    return value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channel(1) + 0.7152 * channel(3) + 0.0722 * channel(5)
end

local function contrast(foreground, background)
  local first, second = luminance(foreground), luminance(background)
  return (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05)
end

require("functions.theme").stop()
for _, background in ipairs({ "light", "dark", "light" }) do
  vim.o.background = background
  local flavour = background == "light" and "latte" or "mocha"
  assert(vim.g.colors_name == "catppuccin-" .. flavour)
  local palette = require("catppuccin.palettes").get_palette(flavour)
  local accents = {
    TODO = palette.sky,
    FIX = palette.red,
    HACK = palette.yellow,
    WARN = palette.yellow,
    PERF = palette.flamingo,
    NOTE = palette.teal,
    TEST = palette.flamingo,
  }
  for _, keyword in ipairs({ "TODO", "FIX", "HACK", "WARN", "PERF", "NOTE", "TEST" }) do
    local group = vim.api.nvim_get_hl(0, { name = "TodoBg" .. keyword, link = false })
    assert(group.bg and group.fg, "missing " .. keyword .. " label colors in " .. flavour)
    local accent = tonumber(accents[keyword]:sub(2), 16)
    assert(group.bg == accent, keyword .. " label lost its palette accent in " .. flavour)
    if background == "light" then
      assert(group.fg == 0xffffff, keyword .. " label must have light text in Latte")
    else
      assert(group.fg == 0x000000, keyword .. " label text changed in Mocha")
      assert(contrast(group.fg, group.bg) >= 4.5,
        keyword .. " label has insufficient contrast in Mocha")
    end
    local trailing = vim.api.nvim_get_hl(0, { name = "TodoFg" .. keyword, link = false })
    assert(trailing.fg == accent, keyword .. " trailing text lost its palette accent")
  end
end

print("Comment integration passed")
