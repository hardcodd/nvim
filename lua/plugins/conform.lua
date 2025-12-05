return {
	"stevearc/conform.nvim",
	event = "BufReadPre",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				html = { "prettier" },
				htmldjango = { "djlint" },
				scss = { "stylelint", "prettier" },
				css = { "stylelint", "prettier" },
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			},
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end,
}
