return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "windwp/nvim-ts-autotag", "nvim-treesitter/nvim-treesitter-context" },
	build = ":TSUpdate",
	config = function()
		vim.cmd([[hi TreesitterContextBottom gui=underline]])

		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true, disable = {} },
			autotag = {
				enable = true,
				enable_rename = true,
				enable_close = true,
				enable_close_on_slash = true,
				filetypes = {
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
