local M = {}
local typescript_root ---@type fun(buf: integer, on_dir: fun(path: string))?

--- Keep upstream project/Deno detection, excluding unnamed TypeScript buffers.
--- vtsls/TypeScript can crash when anonymous markup buffers receive rapid edits.
---@param buf integer
---@param on_dir fun(path: string)
function M.typescript_root(buf, on_dir)
  if vim.api.nvim_buf_get_name(buf) == "" then return end
  if not typescript_root then
    local path = assert(vim.api.nvim_get_runtime_file("lsp/vtsls.lua", false)[1])
    typescript_root = assert(dofile(path).root_dir)
  end
  typescript_root(buf, on_dir)
end

--- Enable native completion and definition lookup for an attached server.
---@param event vim.api.keyset.create_autocmd.callback_args
function M.attach(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then return end
  if client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
  end
  if client:supports_method("textDocument/definition") then
    require("functions.keymaps").n("gd", vim.lsp.buf.definition, "Go to definition", { buffer = event.buf })
  end
end

--- Install and enable only the declared servers, retaining per-server overrides.
function M.setup()
  vim.opt.completeopt = { "menuone", "noselect", "popup" }
  local auto = require("functions.autocmds")
  auto.set("LspAttach", M.attach, "Enable LSP completion and navigation",
    { group = auto.group("LanguageServers") })
  vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    signs = true,
    virtual_text = { spacing = 2, source = "if_many" },
    float = { border = "rounded", source = true },
  })
  local servers = require("config.lsp").servers
  require("mason-lspconfig").setup({
    ensure_installed = servers,
    automatic_enable = servers,
  })
end

return M
