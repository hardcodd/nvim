---@alias KeymapAction string|fun():string?
---@alias ModeMapping fun(keys:string, action:KeymapAction, description:string, options?:vim.keymap.set.Opts)
---@class KeymapHelpers
---@field n ModeMapping
---@field i ModeMapping
---@field v ModeMapping
---@field x ModeMapping
---@field s ModeMapping
---@field o ModeMapping
---@field c ModeMapping
---@field t ModeMapping
local M = {}

---@param value string
---@param name string
local function require_text(value, name)
  assert(type(value) == "string" and value:find("%S"), name .. " must be a nonblank string")
end

--- Register a described mapping; native options override defaults without mutation.
--- Strings are literal key sequences. Wrap Ex commands with cmd() explicitly.
---@param modes string|string[]
---@param keys string
---@param action KeymapAction
---@param description string
---@param options? vim.keymap.set.Opts
function M.set(modes, keys, action, description, options)
  require_text(keys, "keys")
  require_text(description, "description")
  assert(type(action) == "string" or type(action) == "function", "action must be a string or function")
  local resolved = vim.tbl_extend("force", { silent = true, remap = false }, options or {})
  resolved.desc = description
  vim.keymap.set(modes, keys, action, resolved)
end

--- Convert a single-line Ex command to a mapping without changing editor mode.
---@param command string Ex command without a leading colon or trailing Enter.
---@return string
function M.cmd(command)
  require_text(command, "command")
  assert(not command:find("[\r\n]"), "command must be a single line")
  return "<cmd>" .. command .. "<CR>"
end

---@param mode string
---@return ModeMapping
local function for_mode(mode)
  return function(keys, action, description, options)
    M.set(mode, keys, action, description, options)
  end
end

M.n = for_mode("n")
M.i = for_mode("i")
M.v = for_mode("v")
M.x = for_mode("x")
M.s = for_mode("s")
M.o = for_mode("o")
M.c = for_mode("c")
M.t = for_mode("t")

return M
