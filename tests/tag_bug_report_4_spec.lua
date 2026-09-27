local root = vim.fn.getcwd()
local cases = vim.json.decode(table.concat(vim.fn.readfile(
  root .. "/tests/tag_bug_report_4_cases.json"), "\n"))

if vim.env.TAG_B4_CASE then
  cases = vim.tbl_filter(function(case) return case.id == vim.env.TAG_B4_CASE end, cases)
  assert(#cases == 1, "Unknown B4 regression case")
end

local failures = {}
local index = 0
local previous_buffer
local previous_path
local delay = tonumber(vim.env.TAG_B4_DELAY) or 40

local function later(callback)
  vim.defer_fn(function()
    local ok, err = pcall(callback)
    if not ok then
      print("B4 regression runner failed: " .. tostring(err))
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
    print(string.format("B4 regressions: %d cases, %d failures", #cases,
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
