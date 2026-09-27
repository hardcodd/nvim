local root = vim.fn.getcwd()
local cases = vim.json.decode(table.concat(vim.fn.readfile(
  root .. "/tests/tag_bug_report_2_cases.json"), "\n"))

local function add(case)
  cases[#cases + 1] = case
end

add({ id = "B2-01-name-boundary", filetype = "html", extension = "html",
  before = { "<main></main>" }, cursor = { 1, 6 },
  actions = { { keys = "i" }, { paste = "<di", phase = 1 },
    { paste = "v>text", phase = 2 }, { paste = "</div>", phase = 3 },
    { keys = "<Esc>" } },
  expected = { "<main><div>text</div></main>" } })
add({ id = "B2-01-attribute-boundary", filetype = "html", extension = "html",
  before = { "<main></main>" }, cursor = { 1, 6 },
  actions = { { keys = "i" }, { paste = '<div title="a', phase = 1 },
    { paste = '">text', phase = 2 }, { paste = "</div>", phase = 3 },
    { keys = "<Esc>" } },
  expected = { '<main><div title="a">text</div></main>' } })
add({ id = "B2-01-undo", filetype = "html", extension = "html",
  before = { "<main></main>" }, cursor = { 1, 6 },
  actions = { { keys = "i" }, { paste = "<div>", phase = 1 },
    { paste = "text", phase = 2 }, { paste = "</div>", phase = 3 },
    { keys = "<Esc>" }, { keys = "u" } },
  expected = { "<main></main>" } })
add({ id = "B2-04-nested", filetype = "xml", extension = "xml",
  before = { "<main><div><span>b</span></div></main>" }, cursor = { 1, 7 },
  actions = { { keys = "i" }, { keys = string.rep("<Right>", 17) },
    { text = "x" }, { keys = "<Esc>" } },
  expected = { "<main><div><spanx>b</spanx></div></main>" } })

for _, case in ipairs(cases) do
  local pasted = ""
  for _, action in ipairs(case.actions) do
    if action.phase == 1 or action.phase == 2 then
      pasted = pasted .. action.paste
      local initial = case.before[1]
      local col = case.cursor[2]
      action.expected_after = {
        initial:sub(1, col) .. pasted .. initial:sub(col + 1),
      }
    end
  end
end

if vim.env.TAG_B2_CASE then
  cases = vim.tbl_filter(function(case) return case.id == vim.env.TAG_B2_CASE end, cases)
  assert(#cases == 1, "Unknown B2 regression case")
end

local failures = {}
local index = 0
local previous_buffer
local previous_path
local delay = tonumber(vim.env.TAG_B2_DELAY) or 40

local function later(callback)
  vim.defer_fn(function()
    local ok, err = pcall(callback)
    if not ok then
      print("B2 regression runner failed: " .. tostring(err))
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
    print(string.format("B2 regressions: %d cases, %d failures", #cases,
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
  local previous_action
  local function step()
    if previous_action and previous_action.expected_after then
      check(case, previous_action.expected_after, "after phase "
        .. tostring(previous_action.phase))
    end
    action_index = action_index + 1
    local action = actions[action_index]
    if not action then
      check(case, case.expected, "final buffer")
      later(next_case)
      return
    end
    previous_action = action
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
