return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { 
        enable = true,
        disable = { "python", "htmldjango" }
      },
      ensure_installed = {
        "bash",
        "css",
        "html",
        "htmldjango",
        "javascript",
        "json",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
        "python",
        "scss",
        "toml",
        "typescript",
        "yaml"
      },
		})
	end,
}
