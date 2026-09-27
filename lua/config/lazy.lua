local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazy_path) then
  local clone_output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazy_path,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to bootstrap lazy.nvim:\n" .. clone_output)
  end
end

vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({ { import = "plugins" } }, {
  install = { missing = true },
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
