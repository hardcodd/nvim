vim.opt.rtp:prepend(vim.fn.getcwd())
vim.g.mapleader = " "
require("keymaps")

local original_lines = { "alpha beta gamma", "delta epsilon zeta", "eta theta iota" }
vim.api.nvim_buf_set_lines(0, 0, -1, false, original_lines)

local cases = {
  { key = "<C-h>", row = 2, col = 7 },
  { key = "<C-j>", row = 3, col = 8 },
  { key = "<C-k>", row = 1, col = 8 },
  { key = "<C-l>", row = 2, col = 9 },
  { key = "<C-S-h>", row = 2, col = 6 },
  { key = "<C-S-j>", row = 3, col = 8 },
  { key = "<C-S-k>", row = 1, col = 8 },
  { key = "<C-S-l>", row = 2, col = 14 },
}

for _, case in ipairs(cases) do
  assert(vim.fn.maparg(case.key, "i") ~= "", case.key .. " must be mapped in Insert mode")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, original_lines)
  vim.api.nvim_win_set_cursor(0, { 2, 8 })
  vim.api.nvim_feedkeys("i" .. vim.keycode(case.key) .. "X" .. vim.keycode("<Esc>"), "xt", false)
  assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { case.row, case.col }),
    case.key .. " moved to the wrong position")
  local expected_lines = vim.deepcopy(original_lines)
  local line = expected_lines[case.row]
  expected_lines[case.row] = line:sub(1, case.col) .. "X" .. line:sub(case.col + 1)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), expected_lines),
    case.key .. " must only insert the test marker at the destination")
end

print("Insert navigation tests passed")
