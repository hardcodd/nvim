vim.opt.rtp:prepend(vim.fn.getcwd())
vim.treesitter.language.register('bash', 'sh')
local installs, callbacks, starts, warnings = {}, {}, {}, {}
local installed = { lua = true }
package.loaded['nvim-treesitter'] = {
  get_available = function() return { 'lua', 'python', 'bash', 'json', 'vue' } end,
  get_installed = function() return vim.tbl_keys(installed) end,
  install = function(languages)
    local lang = languages[1]
    installs[lang] = (installs[lang] or 0) + 1
    return { await = function(_, callback) callbacks[lang] = callback end }
  end,
}
vim.treesitter.start = function(buf, lang)
  if not installed[lang] then error('missing parser') end
  starts[buf] = lang
end
vim.notify = function(message) warnings[#warnings + 1] = message end

local function buffer(ft, special)
  local buf = vim.api.nvim_create_buf(true, false)
  if special then vim.bo[buf].buftype = 'nofile' end
  vim.bo[buf].filetype = ft
  vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
  return buf
end

require('functions.treesitter').setup()
local lua = buffer('lua')
assert(starts[lua] == 'lua' and not installs.lua, 'installed parser must start without downloading')
local first = buffer('python')
local second = buffer('python')
local deleted = buffer('python')
local changed = buffer('python')
vim.api.nvim_buf_delete(deleted, { force = true })
vim.bo[changed].filetype = 'unknown_test'
assert(installs.python == 1, 'concurrent buffers must share installation')
installed.python = true
callbacks.python()
vim.wait(100, function() return starts[first] ~= nil end)
assert(starts[first] == 'python' and starts[second] == 'python', 'installation must attach all waiting buffers')
assert(not starts[deleted] and not starts[changed], 'stale buffers must not attach')
buffer('unknown_test')
buffer('json', true)
assert(not installs.unknown_test and not installs.json, 'unsupported and special buffers must be ignored')
buffer('sh')
assert(installs.bash == 1, 'filetype must map to parser language')
callbacks.bash('network failure')
vim.wait(100, function() return #warnings > 0 end)
buffer('sh')
assert(installs.bash == 1 and #warnings == 1, 'failed installation must warn once without retry loop')
buffer('json')
callbacks.json()
vim.wait(100, function() return #warnings > 1 end)
assert(#warnings == 2, 'silent installer failure must be detected')
local original_parser, original_query = vim.treesitter.get_parser, vim.treesitter.query.get
vim.treesitter.get_parser = function(_, lang)
  if not installed[lang] then error('missing parser') end
  return {}
end
vim.treesitter.query.get = function() return {} end
local vue = buffer('vue')
vim.bo[vue].indentexpr = 'HtmlIndent()'
require('functions.treesitter').configure_indentation(vue)
assert(vim.bo[vue].indentexpr == 'HtmlIndent()', 'missing parser retains native indentation')
installed.vue = true
callbacks.vue()
vim.wait(100, function() return starts[vue] ~= nil end)
assert(vim.bo[vue].indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()",
  'async install enables component indentation')
vim.bo[vue].indentexpr = 'HtmlIndent()'
vim.treesitter.query.get = function() return nil end
require('functions.treesitter').configure_indentation(vue)
assert(vim.bo[vue].indentexpr == 'HtmlIndent()', 'missing queries retain native indentation')
vim.treesitter.query.get = function() error('invalid query') end
require('functions.treesitter').configure_indentation(vue)
assert(vim.bo[vue].indentexpr == 'HtmlIndent()', 'invalid queries retain native indentation')
vim.bo[lua].indentexpr = 'ExistingIndent()'
require('functions.treesitter').configure_indentation(lua)
assert(vim.bo[lua].indentexpr == 'ExistingIndent()', 'other filetypes retain indentation')
vim.treesitter.get_parser, vim.treesitter.query.get = original_parser, original_query
print('Tree-sitter behavior tests passed')
