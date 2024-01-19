return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.pairs").setup()
		require("mini.comment").setup()
		-- require("mini.indentscope").setup({
		-- 	symbol = "│",
		-- 	options = { try_as_border = true },
		-- })
	end,
}
