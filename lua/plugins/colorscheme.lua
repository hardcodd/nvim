return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = false,
			term_colors = true,
			styles = {
				comments = { "italic" },
				keywords = { "italic" },
				booleans = { "italic" },
			},
			integrations = {
				cmp = true,
				gitsigns = true,
				telescope = true,
				nvimtree = false,
				markdown = true,
				lsp_trouble = false,
				which_key = false,
				dashboard = false,
				barbar = false,
				lsp_saga = false,
				notify = true,
				mini = false,
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
}
