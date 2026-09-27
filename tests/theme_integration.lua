local theme = require("functions.theme")
theme.stop()
local normal_backgrounds = {}
for _, background in ipairs({ "light", "dark", "light" }) do
  vim.o.background = background
  local flavour = background == "light" and "latte" or "mocha"
  assert(vim.g.colors_name == "catppuccin-" .. flavour, "theme did not switch")
  local palette = require("catppuccin.palettes").get_palette(flavour)
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  assert(normal.bg == tonumber(palette.base:sub(2), 16))
  local indent_warning = vim.api.nvim_get_hl(0, { name = "IndentWarning", link = false })
  assert(indent_warning.bg == tonumber(palette.surface0:sub(2), 16),
    "indentation warnings must use the subtle palette background")
  local whitespace = vim.api.nvim_get_hl(0, { name = "Whitespace", link = false })
  assert(whitespace.fg == tonumber(palette.surface1:sub(2), 16),
    "tab and space guides must use the quieter palette foreground")
  local indent_remainder = vim.api.nvim_get_hl(0, { name = "IndentRemainder", link = false })
  assert(indent_remainder.fg == tonumber(palette.overlay0:sub(2), 16),
    "incomplete space levels must keep their readable dot color")
  normal_backgrounds[background] = normal.bg
  for _, name in ipairs({ "@function", "@keyword", "@string", "DiagnosticError", "TelescopeNormal", "TelescopeSelection", "Whitespace" }) do
    local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
    assert(next(highlight) ~= nil, name .. " is missing")
  end
end
assert(normal_backgrounds.light ~= normal_backgrounds.dark)
print("theme integration: both palettes and Tree-sitter/diagnostic/Telescope colors passed")
