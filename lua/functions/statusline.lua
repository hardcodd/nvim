local M = {}
local auto = require("functions.autocmds")

--- Refresh the current buffer's project root outside the redraw path.
---@return nil
function M.update_root()
  vim.b.statusline_root = vim.bo.buftype == "" and (vim.fs.root(0, ".git") or "") or ""
end

--- Show optional detail only when the global statusline has enough columns.
---@return boolean
function M.wide()
  return vim.o.columns >= 100
end

---@return boolean
function M.medium()
  return vim.o.columns >= 80
end

---@return boolean
function M.context()
  return vim.o.columns >= 60
end

--- Keep the editing mode visible on narrow terminals.
---@param label string
---@return string
function M.mode(label)
  return M.context() and label or label:sub(1, 1)
end

--- Format a bounded project-relative path, escaping statusline control text.
--- State markers remain visible even when the filename must be shortened.
---@return string
function M.filename()
  local name = vim.api.nvim_buf_get_name(0)
  local root = vim.b.statusline_root or ""
  if name == "" then
    name = "[No Name]"
  elseif not M.context() then
    name = vim.fn.fnamemodify(name, ":t")
  elseif root ~= "" and name:sub(1, #root + 1) == root .. "/" then
    name = name:sub(#root + 2)
  else
    name = vim.fn.fnamemodify(name, ":~:.")
  end
  local budget = math.max(10, math.floor(vim.o.columns * 0.4))
  if vim.fn.strdisplaywidth(name) > budget then
    name = vim.fn.pathshorten(name)
    while vim.fn.strdisplaywidth(name) > budget - 1 do
      name = vim.fn.strcharpart(name, 1)
    end
    name = "…" .. name
  end
  local markers = (vim.bo.modified and " [+]" or "")
    .. ((vim.bo.readonly or not vim.bo.modifiable) and " [RO]" or "")
  return (name .. markers):gsub("%%", "%%%%")
end

--- Show the effective file encoding, including a byte-order mark when present.
---@return string
function M.encoding()
  local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
  return encoding .. (vim.bo.bomb and " [BOM]" or "")
end

--- Configure one Catppuccin statusline without font or icon dependencies.
---@return nil
function M.setup()
  local group = auto.group("StatuslineProject")
  auto.set({ "BufEnter", "BufFilePost", "DirChanged" }, M.update_root,
    "Cache project root for statusline paths", { group = group })
  M.update_root()
  require("lualine").setup({
    options = {
      theme = "catppuccin-nvim",
      icons_enabled = false,
      globalstatus = true,
      component_separators = { left = "╱", right = "╲" },
      section_separators = { left = "◣", right = "◢" },
    },
    sections = {
      lualine_a = { { "mode", fmt = M.mode } },
      lualine_b = {
        { "branch", cond = M.medium },
        { "diff", cond = M.wide, symbols = { added = "+", modified = "~", removed = "-" } },
      },
      lualine_c = { M.filename },
      lualine_x = {
        { "diagnostics", sources = { "nvim_diagnostic" }, sections = { "error", "warn" },
          symbols = { error = "E:", warn = "W:" } },
        { "searchcount", cond = M.context, timeout = 50, maxcount = 999 },
        { "selectioncount", cond = M.context },
        { "lsp_status", cond = M.wide, symbols = { spinner = { "-", "\\", "|", "/" }, done = "", separator = " " } },
        { "filetype", cond = M.medium },
      },
      lualine_y = { { M.encoding, cond = M.context } },
      lualine_z = { "location" },
    },
  })
end

return M
