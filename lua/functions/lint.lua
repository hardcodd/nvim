local M = {}

--- Discard late lint results after the buffer changes language or closes.
---@param linter lint.Linter
---@param filetype string
---@return lint.Linter
local function for_filetype(linter, filetype)
  local parser = linter.parser
  linter.parser = function(output, buf, cwd)
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= filetype then return {} end
    return parser(output, buf, cwd)
  end
  return linter
end

--- Check markup without rewriting it, resolving project rules from its directory.
--- Missing tools are skipped while Mason installs them; installation failures
--- remain visible in Mason. Special buffers never spawn a process.
---@param event? vim.api.keyset.create_autocmd.callback_args
function M.run(event)
  local buf = event and event.buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then return end
  local lint = require("lint")
  local names = lint.linters_by_ft[vim.bo[buf].filetype] or {}
  for _, linters in pairs(lint.linters_by_ft) do
    for _, name in ipairs(linters) do
      if not vim.list_contains(names, name) then
        vim.diagnostic.reset(lint.get_namespace(name), buf)
      end
    end
  end
  local available = {}
  for _, name in ipairs(names) do
    if vim.fn.executable(lint.linters[name].cmd) == 1 then
      available[#available + 1] = name
    end
  end
  if #available == 0 then return end
  local path = vim.api.nvim_buf_get_name(buf)
  local cwd = path ~= "" and vim.fs.dirname(path) or vim.fn.getcwd()
  vim.api.nvim_buf_call(buf, function()
    lint.try_lint(available, { cwd = cwd })
  end)
end

--- Configure HTML and Django linting, including first-install retry.
function M.setup()
  local lint = require("lint")
  local config = require("config.lint")
  lint.linters_by_ft = config.linters_by_ft
  local djlint = vim.deepcopy(require("lint.linters.djlint"))
  vim.list_extend(djlint.args, { "--profile", "django" })
  djlint.parser = require("lint.parser").from_pattern("(%d+):(%d+):(%a%d+): (.*)",
    { "lnum", "col", "code", "message" }, nil,
    { source = "djlint", severity = vim.diagnostic.severity.WARN }, {})
  lint.linters.djlint = for_filetype(djlint, "htmldjango")
  lint.linters.htmlhint = for_filetype(vim.deepcopy(require("lint.linters.htmlhint")), "html")
  local auto = require("functions.autocmds")
  local group = auto.group("MarkupLint")
  auto.set({ "BufEnter", "BufWritePost", "InsertLeave", "FileType" }, M.run,
    "Check HTML and Django markup", { group = group })
  auto.set("User", M.run, "Check markup after tools install",
    { group = group, pattern = "MasonToolsUpdateCompleted" })
  require("mason-tool-installer").setup({
    ensure_installed = config.tools,
    auto_update = false,
    run_on_start = true,
    integrations = {
      ["mason-lspconfig"] = false,
      ["mason-null-ls"] = false,
      ["mason-nvim-dap"] = false,
    },
  })
end

return M
