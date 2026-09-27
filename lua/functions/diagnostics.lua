local M = {}

--- Jump to the previous diagnostic and show its message.
function M.previous()
  vim.diagnostic.jump({ count = -1, float = true })
end

--- Jump to the next diagnostic and show its message.
function M.next()
  vim.diagnostic.jump({ count = 1, float = true })
end

return M
