local auto = require("functions.autocmds")
local editor = require("functions.editor")

local base_configuration = auto.group("BaseConfiguration")

auto.set("TextYankPost", editor.highlight_yank, "Highlight copied text",
  { group = base_configuration })
auto.set("BufReadPost", editor.restore_position,
  "Restore the last cursor position in normal files", { group = base_configuration })

local indentation_defaults = auto.group("IndentationDefaults")
auto.set("FileType", editor.configure_indentation,
  "Set indentation defaults for the current filetype",
  { group = indentation_defaults, pattern = "*" })

local indent_guides = auto.group("IndentGuides")
auto.set({ "BufEnter", "WinEnter", "FileType" }, editor.update_indent_guides,
  "Refresh indentation guides for the current buffer", { group = indent_guides })
auto.set("OptionSet", editor.update_indent_guides,
  "Refresh indentation guides after indent width changes",
  { group = indent_guides, pattern = { "shiftwidth", "tabstop" } })
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
    editor.configure_indentation({ buf = buf })
  end
end
editor.update_indent_guides()
