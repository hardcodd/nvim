return {
	"lukas-reineke/headlines.nvim",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = {
		markdown = {
			headline_highlights = { "Headline" },
			codeblock_highlight = "CodeBlock",
			dash_highlight = "Dash",
			dash_string = "-",
			quote_highlight = "Quote",
			quote_string = "┃",
			fat_headlines = true,
			fat_headline_upper_string = "▃",
			fat_headline_lower_string = "▀",
		},
	},
	ft = { "markdown", "norg", "rmd", "org" },
	config = function(_, opts)
		-- PERF: schedule to prevent headlines slowing down opening a file
		vim.schedule(function()
			require("headlines").setup(opts)
			require("headlines").refresh()
		end)
	end,
}
