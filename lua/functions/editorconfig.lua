local M = {}

--- Match sections with the same glob conversion used by Neovim 0.12 EditorConfig.
--- Its parser is private; resolving only properties avoids source-buffer creation
--- and the encoding, save-hook, and text changes of the full native configurator.
---@param glob string
---@param directory string
---@return vim.regex?
local function section_pattern(glob, directory)
  glob = glob:find("/") and (directory .. "/" .. glob:gsub("^/", "")) or ("**/" .. glob)
  local placeholder = "@@PLACEHOLDER@@"
  local escaped = vim.fn.substitute(glob:gsub("{(%d+)%.%.(%d+)}", "[%1-%2]"),
    [[\*\@<!\*\*\@!]], placeholder, "g")
  local ok, regex = pcall(vim.fn.glob2regpat, escaped)
  if not ok then return nil end
  local valid, pattern = pcall(vim.regex, (regex:gsub(placeholder, "[^/]*")))
  if valid then return pattern end
end

--- Resolve matching properties afresh, respecting nearest-file and last-section wins.
---@param path string Absolute source filename.
---@return table<string, string>
local function resolve(path)
  local resolved = {} ---@type table<string, string>
  for directory in vim.fs.parents(path) do
    local file = io.open(directory .. "/.editorconfig", "r")
    if file then
      local values = {} ---@type table<string, string>
      local pattern ---@type vim.regex?
      local root = false
      for line in file:lines() do
        if line:find("^%s*[^ #;]") then
          local glob = line:match("^%s*%[(.*)%]%s*$")
          if glob then
            pattern = section_pattern(glob, directory)
          else
            local key, value = line:match("^%s*([^:= ][^:=]-)%s*[:=]%s*(.-)%s*$")
            if key and value then
              key, value = key:lower(), value:lower()
              if key == "root" then
                root = value == "true"
              elseif pattern and pattern:match_str(path) then
                values[key] = value
              end
            end
          end
        end
      end
      file:close()
      for key, value in pairs(values) do
        if resolved[key] == nil then resolved[key] = value end
      end
      if root then break end
    end
  end
  return resolved
end

--- Return the project tab width, or nil when absent, unset, or invalid.
--- Explicit tab_width takes precedence over numeric indent_size, like Neovim.
---@param path string Absolute source filename.
---@return integer?
function M.tab_width(path)
  local properties = resolve(path)
  local value = properties.tab_width or properties.indent_size
  if not value then return nil end
  local width = tonumber(value)
  if width and width % 1 == 0 and width > 0 and width <= 9999 then return width end
end

return M
