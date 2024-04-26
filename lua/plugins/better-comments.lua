return {
	"Djancyp/better-comments.nvim",
	config = function()
		require("better-comment").Setup({
			tags = {
				{
					name = "FIX",
					fg = "#f44747",
					bg = "",
					bold = true,
				},
				{
					name = "WARNING",
					fg = "#FFA500",
					bg = "",
					bold = false,
				},
				{
					name = "!",
					fg = "#f44747",
					bg = "",
					bold = true,
				},
			},
		})
	end,
}
