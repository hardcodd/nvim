return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = require("functions.lsp").setup,
  },
  {
    "mfussenegger/nvim-lint",
    dependencies = { "mason-org/mason.nvim", "WhoIsSethDaniel/mason-tool-installer.nvim" },
    config = require("functions.lint").setup,
  },
}
