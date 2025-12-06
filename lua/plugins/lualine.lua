return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			section_separators = { left = "▓▒░", right = "░▒▓" },
			component_separators = { left = "/", right = "\\" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				{ "diff", colored = false },
				"diagnostics",
				{
					"filename",
					symbols = {
						modified = "●",
						readonly = "",
						unnamed = "[No Name]",
						newfile = "[New]",
					},
				},
				"searchcount",
				"selectioncount",
			},
			lualine_c = {},
			lualine_x = {},
			lualine_y = { "encoding", { "filetype", colored = false }, "progress" },
			lualine_z = { "location" },
		},
	},
}
