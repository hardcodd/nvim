return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
  config = function()
    require("bufferline").setup({
      options = {
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        ---@diagnostic disable-next-line: unused-local
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
      },
      highlights = require("catppuccin.groups.integrations.bufferline").get(),
    })
  end,
}
