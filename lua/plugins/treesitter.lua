return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "windwp/nvim-ts-autotag", "nvim-treesitter/nvim-treesitter-context" },
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true, disable = {} },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-n>", -- init node
					node_incremental = "<C-n>", -- node
					scope_incremental = "<C-s>", -- scope
					node_decremental = "<C-m>", -- node
				},
			},
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
		require("treesitter-context").setup()
	end,
}
