local root = assert(vim.env.NVIM_WEB_TEST_ROOT, "set NVIM_WEB_TEST_ROOT to a disposable npm fixture directory")
vim.fn.writefile({ '{"private":true,"type":"module"}' }, root .. "/package.json")
vim.fn.writefile({
  '{"compilerOptions":{"strict":true,"jsx":"react-jsx","target":"ES2022",',
  '"module":"ESNext","moduleResolution":"Bundler","skipLibCheck":true,',
  '"allowJs":true,"checkJs":true},"include":["*.tsx","*.jsx","*.vue"]}',
}, root .. "/tsconfig.json")
vim.fn.writefile({
  'export default [{ files: ["**/*.jsx"], languageOptions: { parserOptions: {',
  'ecmaVersion: "latest", sourceType: "module", ecmaFeatures: { jsx: true }',
  '} }, rules: { "no-unused-vars": "error" } }];',
}, root .. "/eslint.config.js")
assert(vim.fn.isdirectory(root .. "/node_modules/vue") == 1, "fixture needs Vue 3")
assert(vim.fn.isdirectory(root .. "/node_modules/@types/react") == 1, "fixture needs React types")
assert(vim.fn.isdirectory(root .. "/node_modules/eslint") == 1, "fixture needs ESLint and a config")
local lint = require("lint")

local unnamed = vim.api.nvim_create_buf(true, false)
vim.bo[unnamed].filetype = "typescriptreact"
assert(not vim.lsp.get_clients({ bufnr = unnamed, name = "vtsls" })[1],
  "TypeScript must wait until a buffer has a file name")
vim.api.nvim_buf_delete(unnamed, { force = true })

local function open(name, lines, filetype)
  local path = root .. "/" .. name
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  assert(vim.bo.filetype == filetype, name .. " has unexpected filetype " .. vim.bo.filetype)
  return vim.api.nvim_get_current_buf()
end

local function client(buf, name)
  local found
  assert(vim.wait(15000, function()
    found = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
    return found and found.initialized
  end, 50), name .. " did not attach")
  return found
end

local function diagnostics(buf, source)
  return vim.tbl_filter(function(item) return item.source == source end, vim.diagnostic.get(buf))
end

local function wait_for(message, predicate)
  assert(vim.wait(20000, predicate, 50), message .. ": " .. vim.inspect(vim.diagnostic.get(0)))
end

local function replace(buf, lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf })
end

local html_bad = {
  "<!DOCTYPE html>", '<html lang="en">',
  '<head><meta charset="utf-8"><title>Test</title></head>',
  "<body><main><span>Hello</main></body>", "</html>",
}
local html = open("markup.html", html_bad, "html")
local html_client = client(html, "html")
wait_for("HTMLHint must catch an unclosed span", function()
  return #diagnostics(html, "htmlhint") > 0
end)
local diagnostic = diagnostics(html, "htmlhint")[1]
vim.api.nvim_win_set_cursor(0, { diagnostic.lnum + 1, diagnostic.col })
local windows_before = vim.api.nvim_list_wins()
require("functions.diagnostics").show()
local floating
for _, win in ipairs(vim.api.nvim_list_wins()) do
  if not vim.list_contains(windows_before, win) then floating = win end
end
assert(floating and vim.api.nvim_win_get_config(floating).relative ~= "", "diagnostic message must open a float")
local float_lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(floating), 0, -1, false)
assert(table.concat(float_lines, " "):find(diagnostic.message, 1, true), "float must show the actual error")
vim.api.nvim_win_close(floating, true)
vim.fn.writefile({ '{"tag-pair":false}' }, root .. "/.htmlhintrc")
require("functions.lint").run()
wait_for("HTMLHint must honor project rules", function()
  return #lint.get_running(html) == 0 and #diagnostics(html, "htmlhint") == 0
end)
vim.fn.delete(root .. "/.htmlhintrc")
require("functions.lint").run()
wait_for("removing project override must restore HTML validation", function()
  return #diagnostics(html, "htmlhint") > 0
end)
vim.bo[html].filetype = "htmldjango"
assert(#diagnostics(html, "htmlhint") == 0, "filetype change must clear old HTMLHint diagnostics")
assert(#lint.linters.htmlhint.parser("stdin: line 1, col 1, error - stale (tag-pair)", html, root) == 0,
  "late results from the previous filetype must be discarded")
vim.bo[html].filetype = "html"
local html_good = vim.deepcopy(html_bad)
html_good[4] = "<body><main><span>Hello</span></main></body>"
replace(html, html_good)
wait_for("corrected HTML must clear lint errors", function()
  return #lint.get_running(html) == 0 and #diagnostics(html, "htmlhint") == 0
end)
assert(vim.deep_equal(vim.fn.readfile(root .. "/markup.html"), html_bad), "lint must not write unsaved changes")
vim.api.nvim_buf_set_lines(html, 3, 4, false, { "<body><di" })
local response = html_client:request_sync("textDocument/completion", {
  textDocument = { uri = vim.uri_from_bufnr(html) }, position = { line = 3, character = 9 },
}, 5000, html)
assert(response and response.result, "HTML completion request failed")
local items = response.result.items or response.result
assert(vim.iter(items):any(function(item) return item.label == "div" end), "HTML completion must offer div")
vim.bo[html].modified = false

local typing = open("typing.html", { "" }, "html")
client(typing, "html")
vim.api.nvim_feedkeys(vim.keycode("i<div><CR>content<Esc>"), "xt", false)
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(typing, 0, -1, false),
  { "<div>", "  content", "</div>" }), "LSP completion must preserve paired tag Enter")
vim.bo[typing].modified = false

local django_good = {
  '{% extends "base.html" %}', "{% block content %}",
  '<div class="card">{{ value|default:"empty" }}</div>', "{% endblock content %}",
}
local django = open("templates/template.html", django_good, "htmldjango")
client(django, "html")
require("functions.lint").run()
wait_for("valid Django template must not receive markup errors", function()
  return #lint.get_running(django) == 0 and #diagnostics(django, "djlint") == 0
end)
assert(#diagnostics(django, "htmlhint") == 0, "Django must not run HTMLHint")
local django_bad = vim.deepcopy(django_good)
django_bad[3] = "<div><span>Hello</div>"
replace(django, django_bad)
wait_for("Django orphan tag must be diagnosed", function()
  return vim.iter(diagnostics(django, "djlint")):any(function(item) return item.code == "H025" end)
end)
vim.fn.writefile({ '{"ignore":"H025"}' }, root .. "/.djlintrc")
require("functions.lint").run()
wait_for("djLint must find project rules above the template directory", function()
  return #lint.get_running(django) == 0 and #diagnostics(django, "djlint") == 0
end)
vim.fn.delete(root .. "/.djlintrc")
replace(django, django_good)
wait_for("corrected Django must clear diagnostics", function()
  return #lint.get_running(django) == 0 and #diagnostics(django, "djlint") == 0
end)
vim.bo[django].modified = false

local tsx_bad = {
  "export const App = () => {", '  const count: number = "wrong";',
  "  return <div>{count}</div>;", "};",
}
local tsx = open("App.tsx", tsx_bad, "typescriptreact")
client(tsx, "vtsls")
wait_for("TSX type mismatch must be diagnosed", function()
  return vim.iter(vim.diagnostic.get(tsx)):any(function(item) return item.code == 2322 end)
end)
local tsx_good = vim.deepcopy(tsx_bad)
tsx_good[2] = "  const count: number = 1;"
replace(tsx, tsx_good)
wait_for("corrected TSX must clear errors", function() return #vim.diagnostic.get(tsx) == 0 end)
vim.bo[tsx].modified = false

local jsx = open("Broken.jsx", { "export const Broken = () => <div><span></div>;" }, "javascriptreact")
client(jsx, "vtsls")
wait_for("JSX mismatched tags must be diagnosed", function()
  return vim.iter(vim.diagnostic.get(jsx)):any(function(item)
    return item.source == "ts" and item.severity == vim.diagnostic.severity.ERROR
  end)
end)
replace(jsx, { "export const Broken = () => <div><span /></div>;" })
wait_for("corrected JSX must clear errors", function() return #vim.diagnostic.get(jsx) == 0 end)
vim.bo[jsx].modified = false

local eslint_buf = open("Lint.jsx", { "const unused = 1;", "export const App = () => <div />;" }, "javascriptreact")
client(eslint_buf, "eslint")
wait_for("ESLint must use project rules", function()
  return vim.iter(diagnostics(eslint_buf, "eslint")):any(function(item) return item.code == "no-unused-vars" end)
end)
replace(eslint_buf, { "export const App = () => <div />;" })
wait_for("corrected ESLint diagnostics must clear", function()
  return #diagnostics(eslint_buf, "eslint") == 0
end)
vim.bo[eslint_buf].modified = false

local vue_bad = {
  '<script setup lang="ts">', 'const count: number = "wrong";', "</script>",
  "<template><div>{{ count }}</div></template>",
}
local vue = open("Example.vue", vue_bad, "vue")
client(vue, "vtsls")
client(vue, "vue_ls")
wait_for("Vue script type mismatch must be diagnosed", function()
  return vim.iter(vim.diagnostic.get(vue)):any(function(item) return item.code == 2322 end)
end)
local vue_good = vim.deepcopy(vue_bad)
vue_good[2] = "const count: number = 1;"
replace(vue, vue_good)
wait_for("corrected Vue script must clear errors", function() return #vim.diagnostic.get(vue) == 0 end)
local vue_template_bad = vim.deepcopy(vue_good)
vue_template_bad[4] = "<template><div><span>{{ count }}</div></template>"
replace(vue, vue_template_bad)
wait_for("Vue template mismatched tags must be diagnosed", function()
  return vim.iter(vim.diagnostic.get(vue)):any(function(item)
    return item.severity == vim.diagnostic.severity.ERROR
  end)
end)
replace(vue, vue_good)
wait_for("corrected Vue template must clear errors", function() return #vim.diagnostic.get(vue) == 0 end)
vim.bo[vue].modified = false

for _, active in ipairs(vim.lsp.get_clients()) do
  assert(active.name ~= "ts_ls", "competing TypeScript server attached")
end
require("functions.theme").stop()
for _, active in ipairs(vim.lsp.get_clients()) do active:stop(true) end
print("Real HTML, Django, JSX/TSX, ESLint and Vue diagnostics passed")
