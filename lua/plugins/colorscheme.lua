return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function(_, opts)
    opts.transparent_background = true
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
    vim.opt.background = "light"
  end,
}
