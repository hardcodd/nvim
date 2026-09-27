local root = vim.fn.getcwd()
local cases = vim.json.decode(table.concat(vim.fn.readfile(
  root .. "/tests/tag_bug_report_3_cases.json"), "\n"))

local function add(case)
  cases[#cases + 1] = case
end

local spaced = '<main><div id="x">text</div  ><aside>end</aside></main>'
local closer = assert(spaced:find("</div", 1, true))
add({ id = "B3-05-two-spaces-attribute", filetype = "xml", extension = "xml",
  before = { spaced }, cursor = { 1, closer + 1 },
  actions = { { keys = "diw" }, { keys = "i" },
    { text = "section", slow = true }, { keys = "<Esc>" } },
  expected = { '<main><section id="x">text</section  ><aside>end</aside></main>' } })
local quoted = 'const x = "<div>text</div>";'
add({ id = "B3-02-jsx-string-control", filetype = "javascriptreact",
  extension = "jsx", before = { quoted },
  cursor = { 1, assert(quoted:find("<div", 1, true)) + 1 },
  actions = { { keys = "ciw" }, { text = "section" },
    { keys = "<Esc>" } },
  expected = { 'const x = "<section>text</div>";' } })
local comparison = 'const result = left < div > right; const text = "</div>";'
add({ id = "B3-02-jsx-comparison-control", filetype = "javascriptreact",
  extension = "jsx", before = { comparison },
  cursor = { 1, assert(comparison:find("< div", 1, true)) + 1 },
  actions = { { keys = "ciw" }, { text = "section" },
    { keys = "<Esc>" } },
  expected = { 'const result = left < section > right; const text = "</div>";' } })
local jsx_path = [=[<main><div title="C:\">text</div><aside>end</aside></main>]=]
add({ id = "B3-02-jsx-backslash-attribute", filetype = "javascriptreact",
  extension = "jsx", before = { jsx_path },
  cursor = { 1, assert(jsx_path:find("<div", 1, true)) + 1 },
  actions = { { keys = "ciw" }, { text = "section" },
    { keys = "<Esc>" } },
  expected = { [=[<main><section title="C:\">text</section><aside>end</aside></main>]=] } })
local vue_literal = '  "prefix {{ <span>text</span>"'
add({ id = "B3-04-braces-inside-literal", filetype = "vue",
  extension = "vue", before = { "<main>{{", vue_literal, "}}</main>" },
  cursor = { 2, assert(vue_literal:find("<span", 1, true)) + 1 },
  actions = { { keys = "ciw" }, { text = "section" },
    { keys = "<Esc>" } },
  expected = { "<main>{{", '  "prefix {{ <section>text</span>"',
    "}}</main>" } })

if vim.env.TAG_B3_CASE then
  cases = vim.tbl_filter(function(case) return case.id == vim.env.TAG_B3_CASE end, cases)
  assert(#cases == 1, "Unknown B3 regression case")
end

local failures = {}
local index = 0
local previous_buffer
local previous_path
local delay = tonumber(vim.env.TAG_B3_DELAY) or 40

local function later(callback)
  vim.defer_fn(function()
    local ok, err = pcall(callback)
    if not ok then
      print("B3 regression runner failed: " .. tostring(err))
      vim.cmd("cquit")
    end
  end, delay)
end

local function check(case, expected, label)
  local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if not vim.deep_equal(actual, expected) then
    failures[#failures + 1] = case.id .. " " .. label .. ": expected "
      .. vim.inspect(expected) .. ", got " .. vim.inspect(actual)
  end
end

local next_case
next_case = function()
  index = index + 1
  local case = cases[index]
  if not case then
    if previous_buffer then
      vim.cmd("enew!")
      vim.api.nvim_buf_delete(previous_buffer, { force = true })
      vim.fn.delete(previous_path)
    end
    for _, failure in ipairs(failures) do print(failure) end
    print(string.format("B3 regressions: %d cases, %d failures", #cases,
      #failures))
    vim.cmd(#failures == 0 and "qa!" or "cquit")
    return
  end

  vim.cmd("stopinsert")
  local path = vim.fn.tempname() .. "." .. case.extension
  vim.fn.writefile(case.before, path)
  vim.cmd("silent edit! " .. vim.fn.fnameescape(path))
  if previous_buffer then
    vim.api.nvim_buf_delete(previous_buffer, { force = true })
    vim.fn.delete(previous_path)
  end
  previous_buffer = vim.api.nvim_get_current_buf()
  previous_path = path
  vim.bo.filetype = case.filetype
  vim.api.nvim_win_set_cursor(0, case.cursor)
  check(case, case.before, "initial buffer")
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  assert(ok and parser and pcall(function() parser:parse() end),
    case.id .. " parser unavailable")

  local actions = {}
  for _, action in ipairs(case.actions) do
    if action.slow then
      for _, char in ipairs(vim.fn.split(action.text, "\\zs")) do
        actions[#actions + 1] = { text = char }
      end
    else
      actions[#actions + 1] = action
    end
  end
  local action_index = 0
  local function step()
    action_index = action_index + 1
    local action = actions[action_index]
    if not action then
      check(case, case.expected, "final buffer")
      later(next_case)
      return
    end
    if action.text then
      vim.api.nvim_input((action.text:gsub("<", "<LT>")))
    elseif action.keys then
      vim.api.nvim_input(action.keys)
    elseif action.cursor then
      vim.api.nvim_win_set_cursor(0, action.cursor)
    elseif action.paste then
      assert(vim.api.nvim_paste(action.paste, action.crlf or false,
        action.phase or -1), "Paste rejected")
    end
    later(step)
  end
  later(step)
end

later(next_case)
