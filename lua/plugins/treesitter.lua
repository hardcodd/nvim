return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "windwp/nvim-ts-autotag" },
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			autotag = {
				enable = true,
				enable_rename = true,
				enable_close = true,
				enable_close_on_slash = true,
				{
					"html",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
					"tsx",
					"jsx",
					"rescript",
					"xml",
					"php",
					"markdown",
					"astro",
					"glimmer",
					"handlebars",
					"hbs",
				},
			},
		})
	end,
}
