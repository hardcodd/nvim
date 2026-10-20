-- Run with the real configuration and a Mason-installed Emmet server.
vim.opt.clipboard = ""
-- Vue diagnostics are covered separately; avoid its TypeScript dependency in anonymous buffers.
vim.lsp.enable("vue_ls", false)
local runner
local function resume()
  local ok, err = coroutine.resume(runner)
  if not ok then print(err); vim.cmd("cquit") end
end
local function feed(keys)
  vim.api.nvim_input(keys)
  vim.defer_fn(resume, 250)
  coroutine.yield()
end
local function lines()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end
local function open(ft, text, row)
  feed("<Esc>")
  vim.snippet.stop()
  vim.bo.modified = false
  vim.cmd.enew()
  vim.bo.filetype = ft
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.api.nvim_win_set_cursor(0, { row or 1, 0 })
  assert(vim.wait(10000, function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = "emmet_language_server" })[1]
    return client and client.initialized
  end, 20), "Emmet did not attach to " .. ft)
end
local function expand(expected)
  feed("A<Tab>")
  assert(vim.wait(5000, function() return lines():find(expected, 1, true) ~= nil end, 10),
    "missing expansion " .. expected .. ": " .. lines() .. " mode=" .. vim.api.nvim_get_mode().mode)
end

runner = coroutine.create(function()
  open("html", "  ul>li.item$*3")
  expand('<li class="item3"></li>')
  assert(lines() == '  <ul>\n    <li class="item1"></li>\n    <li class="item2"></li>\n    <li class="item3"></li>\n  </ul>', lines())
  open("html", "!")
  expand("<!DOCTYPE html>")
  assert(vim.snippet.active({ direction = 1 }), "doctype expansion has editable fields")
  local before = lines()
  local first = vim.api.nvim_win_get_cursor(0)
  feed("<Tab>")
  local second = vim.api.nvim_win_get_cursor(0)
  assert(not vim.deep_equal(first, second), "Tab must move to next field")
  feed("<S-Tab>")
  assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), first), "Shift-Tab must return to previous field")
  assert(lines() == before, "field navigation must preserve text")
  open("htmldjango", "{% block content %}\n  .card\n{% endblock %}", 2)
  expand('<div class="card"></div>')
  assert(lines():find("{% endblock %}", 1, true), "preserve Django delimiters")
  for _, ft in ipairs({ "javascriptreact", "typescriptreact" }) do
    open(ft, "const App = () => (\n  .card\n);", 2)
    expand('<div className="card"></div>')
  end
  open("vue", "<template>\n  .card\n</template>", 2)
  expand('<div class="card"></div>')
  open("css", ".card {\n  m10\n}", 2)
  expand("margin: 10px;")
  open("vue", "<style>\n.card {\n  m10\n}\n</style>", 3)
  expand("margin: 10px;")
  open("html", "    ")
  feed("A<Tab>")
  assert(not lines():find("<", 1, true) and #lines() > 4, "whitespace Tab must indent")
  open("html", '<div class="')
  feed("A<Tab>")
  assert(lines():find('<div class="', 1, true) == 1 and not lines():find("</", 1, true),
    "inside a tag, no completion must fall back to Tab")
  open("html", "Привет .card")
  expand('<div class="card"></div>')
  assert(lines():find("Привет ", 1, true) == 1, "LSP UTF-16 edit must preserve the prefix")
  open("html", "")
  feed("i<LT>div><CR>content<Esc>")
  assert(lines() == "<div>\n  content\n</div>", "paired tag Enter survives Emmet: " .. lines())
  open("html", "")
  feed("idiv")
  assert(vim.wait(3000, function() return vim.fn.pumvisible() == 1 end, 10), "typed abbreviation opens completion")
  feed("<C-n><Tab>")
  assert(lines() == "<div></div>", "Tab accepts a selected native completion: " .. lines())

  -- A response arriving after another edit must not replace the new text.
  open("html", "div")
  local client = vim.lsp.get_clients({ bufnr = 0, name = "emmet_language_server" })[1]
  local request = client.request
  local respond
  client.request = function(_, _, _, callback) respond = callback; return true, 999 end
  feed("A<Tab>")
  assert(respond, "Tab must request expansion")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "new text" })
  respond(nil, { items = { { textEdit = { range = {
      start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 3 },
    }, newText = "<div>$0</div>" } } } })
  assert(lines() == "new text", "late response must not change edited text")
  client.request = request
  feed("<Esc>")
  require("functions.theme").stop()
  for _, active in ipairs(vim.lsp.get_clients()) do active:stop(true) end
  print("Real Emmet expansion, indentation, snippet navigation and stale response checks passed")

  vim.cmd("qa!")
end)
vim.schedule(resume)
