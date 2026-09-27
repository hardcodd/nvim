local M = {}

---@param value string
---@param name string
local function require_text(value, name)
  assert(type(value) == "string" and value:find("%S"), name .. " must be a nonblank string")
end

--- Create a named group, clearing registrations from a previous setup.
---@param name string
---@return integer
function M.group(name)
  require_text(name, "group name")
  return vim.api.nvim_create_augroup(name, { clear = true })
end

--- Register a described callback while preserving caller-owned native options.
---@param events vim.api.keyset.events|vim.api.keyset.events[]
---@param callback fun(event:vim.api.keyset.create_autocmd.callback_args):boolean?
---@param description string
---@param options? vim.api.keyset.create_autocmd
---@return integer
function M.set(events, callback, description, options)
  if type(events) == "table" then
    assert(#events > 0, "events must not be empty")
    for _, event in ipairs(events) do
      require_text(event, "event")
    end
  else
    require_text(events, "events")
  end
  assert(type(callback) == "function", "callback must be a function")
  require_text(description, "description")
  local resolved = vim.tbl_extend("force", options or {}, {
    callback = callback,
    desc = description,
  })
  return vim.api.nvim_create_autocmd(events, resolved)
end

return M
