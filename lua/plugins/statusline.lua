return {
  "nvim-lualine/lualine.nvim",
  commit = "221ce6b2d999187044529f49da6554a92f740a96",
  lazy = false,
  dependencies = { { "catppuccin/nvim", name = "catppuccin" } },
  config = require("functions.statusline").setup,
}
