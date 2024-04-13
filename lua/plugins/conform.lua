return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform will run multiple formatters sequentially
			python = { "isort", "black", "autopep8" },
			-- Use a sub-list to run only the first available formatter
			javascript = { "prettier" },

			html = { "prettier" },
			htmldjango = { "djlint" },
			markdown = { "prettier" },
		},
		format_after_save = {
			lsp_fallback = true,
		},
	},
}
