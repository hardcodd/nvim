return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "latte",
		background = { -- :h background
			light = "latte",
			dark = "mocha",
		},
		transparent_background = false, -- disables setting the background color.
		term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
		styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
			comments = { "italic" }, -- Change the style of comments
			conditionals = { "italic" },
			loops = {},
			functions = {},
			keywords = {},
			strings = {},
			variables = {},
			numbers = {},
			booleans = { "italic" },
			properties = {},
			types = {},
			operators = {},
		},
		integrations = {
			cmp = true,
			gitsigns = true,
			treesitter = true,
			notify = true,
			noice = true,
			indent_blankline = { enabled = true },
			lsp_trouble = true,
			mason = true,
			markdown = true,
			mini = true,
			telescope = true,
			treesitter_context = true,
			native_lsp = {
				enabled = true,
				underlines = {
					errors = { "undercurl" },
					hints = { "undercurl" },
					warnings = { "undercurl" },
					information = { "undercurl" },
				},
			},
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
		vim.opt.background = "light"
	end,
}
