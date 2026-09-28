local M = {}

--- Enable paired punctuation while preserving paired-tags.nvim's Enter mapping.
---@return nil
function M.autopairs()
  require("nvim-autopairs").setup({ map_cr = false })
end

--- Handle Vue script and style content without changing tags or injected languages.
---@param context CommentCtx
---@return string?
local function vue_raw_text_commentstring(context)
  if vim.bo.filetype ~= "vue" then return nil end
  local ok, node = pcall(vim.treesitter.get_node, {
    bufnr = 0,
    pos = { context.range.srow - 1, context.range.scol },
    ignore_injections = true,
  })
  if not ok then return nil end
  while node do
    if node:type() == "raw_text" then
      local parent = node:parent()
      local kind = parent and parent:type()
      local block = context.ctype == require("Comment.utils").ctype.blockwise
      if kind == "script_element" then return block and "/* %s */" or "// %s" end
      if kind == "style_element" then return "/* %s */" end
      return nil
    end
    node = node:parent()
  end
  return nil
end

--- Configure context-aware line and block commenting after dependencies load.
---@return nil
function M.comments()
  local context_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
  require("Comment").setup({
    pre_hook = function(context)
      local commentstring = context_hook(context)
      if commentstring ~= "<!-- %s -->" then return commentstring end
      return vue_raw_text_commentstring(context) or commentstring
    end,
  })
end

--- Resolve TODO comment captures after Django templates inject their HTML tree.
--- The plugin can inspect a template before asynchronous injected parsing ends.
---@param _ table
---@param opts TodoOptions
---@return nil
function M.todo_comments(_, opts)
  local highlighter = require("todo-comments.highlight")
  local original_is_comment = highlighter.is_comment
  highlighter.is_comment = function(buf, row, col)
    local result = original_is_comment(buf, row, col)
    if result or vim.bo[buf].filetype ~= "htmldjango"
      or not vim.treesitter.highlighter.active[buf] then
      return result
    end
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok or not parser then return result end
    -- Parse only the candidate line so injected HTML captures are available now.
    local parsed = pcall(parser.parse, parser, { row, 0, row, col + 1 })
    return parsed and original_is_comment(buf, row, col) or result
  end
  require("todo-comments").setup(opts)
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
