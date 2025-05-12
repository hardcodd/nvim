return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			show_close_icon = false,
			show_buffer_close_icons = true,
			separator_style = "slant", -- "slant" | "slope" | "thick" | "thin"
			always_show_bufferline = true,
		},
	},
}
