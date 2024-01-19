return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.pairs").setup()
		require("mini.comment").setup()
		require("mini.indentscope").setup({
			symbol = "│",
			mappings = {
				goto_top = "gt",
				goto_bottom = "gb",
			},
			options = { try_as_border = true },
		})
	end,
}
