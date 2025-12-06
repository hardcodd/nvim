return {
	"Kicamon/markdown-table-mode.nvim",
	ft = "markdown",
	config = function()
		require("markdown-table-mode").setup({
			options = {
				insert = true, -- when typing "|"
				insert_leave = true, -- when leaving insert
				pad_separator_line = false, -- add space in separator line
				align_style = "default", -- default, left, center, right
			},
		})
		-- Run :Mtm command on a mardkdown file is opened
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.cmd.Mtm()
			end,
		})
	end,
}
