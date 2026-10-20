local M = {}

--- Show the diagnostic message at the cursor.
function M.show()
  vim.diagnostic.open_float(nil, { scope = "cursor" })
end

--- Jump to the previous diagnostic and show its message.
function M.previous()
  vim.diagnostic.jump({ count = -1, float = true })
end

--- Jump to the next diagnostic and show its message.
function M.next()
  vim.diagnostic.jump({ count = 1, float = true })
end

return M
