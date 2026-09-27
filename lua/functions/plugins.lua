local M = {}

--- Enable paired punctuation while preserving paired-tags.nvim's Enter mapping.
---@return nil
function M.autopairs()
  require("nvim-autopairs").setup({ map_cr = false })
end

--- Match preview tab rendering without loading the source or changing its options.
--- Project EditorConfig overrides loaded-source or filetype fallback widths.
---@param event { buf: integer, data?: { bufname?: string, filetype?: string } }
---@return nil
function M.telescope_preview_tabs(event)
  if not vim.api.nvim_buf_is_valid(event.buf) then return end
  local data = event.data or {}
  local source_buffer ---@type integer?
  local path ---@type string?
  if data.bufname and data.bufname ~= "" then
    path = vim.fn.resolve(vim.fn.fnamemodify(data.bufname, ":p"))
    for _, source in ipairs(vim.api.nvim_list_bufs()) do
      if source ~= event.buf and vim.api.nvim_buf_is_loaded(source)
        and vim.bo[source].buftype == ""
        and vim.fn.resolve(vim.api.nvim_buf_get_name(source)) == path then
        source_buffer = source
        break
      end
    end
  end

  local tabstop = vim.go.tabstop
  local vartabstop = vim.go.vartabstop
  if source_buffer then
    tabstop = vim.bo[source_buffer].tabstop
    vartabstop = vim.bo[source_buffer].vartabstop
  elseif data.filetype and data.filetype ~= "" then
    tabstop = require("functions.editor").indentation_defaults(data.filetype)
    local filetype_vartabstop = vim.filetype.get_option(data.filetype, "vartabstop")
    if type(filetype_vartabstop) == "string" then vartabstop = filetype_vartabstop end
  end
  if path then
    tabstop = require("functions.editorconfig").tab_width(path) or tabstop
  end
  vim.bo[event.buf].tabstop = tabstop
  vim.bo[event.buf].vartabstop = vartabstop
end

--- Configure Telescope after lazy.nvim has loaded the plugin.
---@return nil
function M.telescope()
  local auto = require("functions.autocmds")
  auto.set("User", M.telescope_preview_tabs, "Match preview tab widths to the editor", {
    group = auto.group("TelescopePreviewTabs"), pattern = "TelescopePreviewerLoaded",
  })
  require("telescope").setup({
    defaults = {
      mappings = require("keymaps").telescope,
      layout_config = { scroll_speed = 2 },
    },
  })
end

return M
