local M = {}
local auto = require("functions.autocmds")

--- Use syntax-aware indentation for component files when installed queries exist.
--- Called after native indent scripts and again after asynchronous parser installs.
---@param buf integer
---@return nil
function M.configure_indentation(buf)
  local ft = vim.bo[buf].filetype
  if vim.bo[buf].buftype ~= "" or
    (ft ~= "vue" and ft ~= "typescriptreact" and ft ~= "javascriptreact") then
    return
  end
  local lang = vim.treesitter.language.get_lang(ft)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
  if not ok or not parser then return end
  local has_query, query = pcall(vim.treesitter.query.get, lang, "indents")
  if not has_query or not query then return end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

--- Enable highlighting and install missing parsers once per language per session.
--- Pending installs are shared; closed or repurposed buffers are never attached.
function M.setup()
  local treesitter = require("nvim-treesitter")
  local available = {} ---@type table<string, boolean>
  local attempted = {} ---@type table<string, boolean>
  local waiting = {} ---@type table<string, table<integer, boolean>>
  for _, lang in ipairs(treesitter.get_available()) do
    available[lang] = true
  end

  ---@param buf integer
  ---@return string?
  local function language(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf)
      or vim.bo[buf].buftype ~= "" then
      return nil
    end
    return vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  end

  ---@param lang string
  ---@return boolean
  local function installed(lang)
    return vim.list_contains(treesitter.get_installed("parsers"), lang)
      and vim.list_contains(treesitter.get_installed("queries"), lang)
  end

  ---@param buf integer
  local function enable(buf)
    local lang = language(buf)
    if not lang then return end
    -- Bundled or previously installed parsers remain useful while offline.
    pcall(vim.treesitter.start, buf, lang)
    if not available[lang] or installed(lang) then return end
    if waiting[lang] then
      waiting[lang][buf] = true
      return
    end
    if attempted[lang] then return end
    attempted[lang] = true
    waiting[lang] = { [buf] = true }

    ---@param err unknown?
    local function finish(err)
      vim.schedule(function()
        local buffers = waiting[lang] or {}
        waiting[lang] = nil
        if err or not installed(lang) then
          vim.notify("Tree-sitter: installation failed for " .. lang
            .. ". See :TSLog; retry with :TSInstall " .. lang
            .. " and reopen the buffer.", vim.log.levels.WARN)
          return
        end
        for target in pairs(buffers) do
          if language(target) == lang then
            pcall(vim.treesitter.start, target, lang)
            M.configure_indentation(target)
          end
        end
      end)
    end

    local ok, err = pcall(function()
      treesitter.install({ lang }):await(finish)
    end)
    if not ok then finish(err) end
  end

  local group = auto.group("TreesitterHighlighting")
  auto.set("FileType", function(event) enable(event.buf) end,
    "Install language parser and enable Tree-sitter highlighting", { group = group })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    enable(buf)
  end
end

return M
