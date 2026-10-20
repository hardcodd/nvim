local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(root .. "/after")

local setup_options
package.preload["mason-lspconfig"] = function()
  return { setup = function(options) setup_options = options end }
end
local lsp = require("functions.lsp")
local unnamed = vim.api.nvim_create_buf(true, false)
local started = false
lsp.typescript_root(unnamed, function() started = true end)
assert(not started, "TypeScript must not start for an unnamed buffer")
vim.api.nvim_buf_delete(unnamed, { force = true })
lsp.setup()
lsp.setup()
assert(#vim.api.nvim_get_autocmds({ group = "LanguageServers" }) == 1,
  "repeated setup must not duplicate attach handlers")
local servers = setup_options.automatic_enable
assert(vim.deep_equal(servers, setup_options.ensure_installed), "enable only declared servers")
assert(not vim.list_contains(servers, "ts_ls"), "do not start competing TypeScript servers")
assert(vim.diagnostic.config().virtual_text and vim.diagnostic.config().severity_sort)

local enabled
local original_client = vim.lsp.get_client_by_id
local original_completion = vim.lsp.completion.enable
vim.lsp.get_client_by_id = function(id)
  if id == 999 then return nil end
  return {
    id = id,
    supports_method = function(_, method)
      return method == "textDocument/completion" or method == "textDocument/definition"
    end,
  }
end
vim.lsp.completion.enable = function(value, client_id, bufnr, options)
  enabled = { value, client_id, bufnr, options.autotrigger }
end
local buf = vim.api.nvim_create_buf(true, false)
lsp.attach({ buf = buf, data = { client_id = 1 } })
assert(vim.deep_equal(enabled, { true, 1, buf, true }), "enable native completion in the attached buffer")
assert(#vim.api.nvim_buf_get_keymap(buf, "n") == 1, "definition mapping must be buffer-local")
assert(vim.fn.maparg("gd", "n") == "", "unattached buffers keep native gd")
lsp.attach({ buf = buf, data = { client_id = 999 } })
vim.lsp.get_client_by_id = original_client
vim.lsp.completion.enable = original_completion

local html = dofile(root .. "/after/lsp/html.lua")
assert(vim.list_contains(html.filetypes, "htmldjango"), "Django templates need HTML completion")
assert(html.init_options.provideFormatter == false, "HTML formatter must not rewrite Django syntax")
local vtsls = dofile(root .. "/after/lsp/vtsls.lua")
assert(vim.list_contains(vtsls.filetypes, "vue"), "TypeScript must attach to Vue script blocks")
local plugin = vtsls.settings.vtsls.tsserver.globalPlugins[1]
assert(plugin.name == "@vue/typescript-plugin" and vim.list_contains(plugin.languages, "vue"))

local calls = {}
local lint = {
  linters_by_ft = { html = { "htmlhint" }, htmldjango = { "djlint" } },
  linters = { htmlhint = { cmd = "htmlhint" }, djlint = { cmd = "djlint" } },
  get_namespace = function(name) return vim.api.nvim_create_namespace(name) end,
  try_lint = function(names, options)
    calls[#calls + 1] = { vim.bo.filetype, names, options.cwd, vim.api.nvim_get_current_buf() }
  end,
}
package.loaded.lint = lint
local original_executable = vim.fn.executable
vim.fn.executable = function(cmd) return cmd == "htmlhint" and 1 or 0 end
vim.api.nvim_buf_set_name(buf, "/private/tmp/project/templates/example.html")
vim.bo[buf].filetype = "html"
local markup = require("functions.lint")
markup.run({ buf = buf })
assert(vim.deep_equal(calls[1], { "html", { "htmlhint" }, "/private/tmp/project/templates", buf }),
  "lint the event buffer, using its directory rather than Neovim's working directory")
assert(vim.api.nvim_get_current_buf() ~= buf, "linting must restore the current buffer")
vim.bo[buf].filetype = "htmldjango"
vim.diagnostic.set(lint.get_namespace("htmlhint"), buf,
  { { lnum = 0, col = 0, message = "old HTML diagnostic" } })
markup.run({ buf = buf })
assert(#calls == 1, "do not spawn tools still being installed")
assert(#vim.diagnostic.get(buf, { namespace = lint.get_namespace("htmlhint") }) == 0,
  "changing filetype must clear diagnostics from the previous linter")
vim.fn.executable = function() return 1 end
markup.run({ buf = buf })
assert(calls[2][2][1] == "djlint", "Django templates must not run HTMLHint")
vim.bo[buf].buftype = "nofile"
markup.run({ buf = buf })
assert(#calls == 2, "special buffers must not spawn linters")
vim.api.nvim_buf_delete(buf, { force = true })
markup.run({ buf = buf })
vim.fn.executable = original_executable

print("LSP and markup routing checks passed")
