local M = {}
local auto = require("functions.autocmds")
---@type uv.uv_timer_t?
local timer
local generation = 0
local pending = false
local active = false

--- Calculate sRGB luminance to distinguish light and dark Catppuccin palettes.
---@param color string Hex RGB color.
---@return number
local function luminance(color)
  ---@param start integer
  ---@return number
  local function linear_channel(start)
    local value = tonumber(color:sub(start, start + 1), 16) / 255
    return value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * linear_channel(2)
    + 0.7152 * linear_channel(4) + 0.0722 * linear_channel(6)
end

--- Rebuild theme highlights so TODO labels follow the active palette.
---@param colors table<string, string>
---@return table<string, table<string, string|boolean>>
function M.highlights(colors)
  local highlights = {
    Whitespace = { fg = colors.surface1 },
    IndentRemainder = { fg = colors.overlay0 },
    IndentWarning = { bg = colors.surface0 },
  }
  local todo_accents = {
    TODO = colors.sky,
    FIX = colors.red,
    HACK = colors.yellow,
    WARN = colors.yellow,
    PERF = colors.flamingo,
    NOTE = colors.teal,
    TEST = colors.flamingo,
  }
  local light_palette = luminance(colors.base) > 0.5
  for keyword, accent in pairs(todo_accents) do
    highlights["TodoBg" .. keyword] = {
      bg = accent, fg = light_palette and "#ffffff" or "#000000", bold = true,
    }
    highlights["TodoFg" .. keyword] = { fg = accent }
  end
  return highlights
end

--- Release the appearance timer and invalidate outstanding process callbacks.
---@return nil
function M.stop()
  active = false
  generation = generation + 1
  pending = false
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

--- Refresh macOS appearance without blocking editing or overlapping reads.
--- Failed reads retain the current appearance and retry on the next tick.
---@return nil
function M.refresh()
  if not active or pending then return end
  pending = true
  local request_generation = generation
  local ok = pcall(vim.system, { "/usr/bin/defaults", "read", "-g" }, {
    text = true,
    timeout = 2000,
  }, vim.schedule_wrap(function(result)
    if request_generation ~= generation then return end
    pending = false
    local output = result.stdout or ""
    if result.code ~= 0 or not output:match("^%s*{.*}%s*$") then return end
    -- A successful preferences read with no style key denotes light mode.
    local style = output:match('[\r\n]%s*"?AppleInterfaceStyle"?%s*=%s*"?([%a]+)"?%s*;')
    if style and style ~= "Dark" and style ~= "Light" then return end
    local background = style == "Dark" and "dark" or "light"
    if vim.o.background ~= background then
      vim.o.background = background
    end
  end))
  if not ok then pending = false end
end

--- Load Catppuccin and follow macOS appearance; other OSes use 'background'.
--- Calling setup again replaces the watcher instead of creating duplicates.
---@return nil
function M.setup()
  M.stop()
  require("catppuccin").setup({
    flavour = "auto",
    background = { light = "latte", dark = "mocha" },
    auto_integrations = true,
    custom_highlights = M.highlights,
  })
  vim.cmd.colorscheme("catppuccin-nvim")
  local group = auto.group("SystemAppearance")
  if vim.fn.has("macunix") ~= 1 then return end
  active = true
  auto.set("FocusGained", M.refresh, "Refresh system appearance", { group = group })
  auto.set("VimLeavePre", M.stop, "Stop system appearance watcher", { group = group })
  timer = assert(vim.uv.new_timer())
  timer:start(3000, 3000, vim.schedule_wrap(M.refresh))
  M.refresh()
end

return M
