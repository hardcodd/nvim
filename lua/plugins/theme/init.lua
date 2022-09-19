local config = require("onedarkpro.config").config
vim.o.background = "light"

require("onedarkpro").setup({
	dark_theme = "onedark", -- The default dark theme
	light_theme = "onelight", -- The default light theme
	-- The theme function can be overwritten with a string value for the theme
	theme = function()
		if vim.o.background == "dark" then
			return config.dark_theme
		else
			return config.light_theme
		end
	end,
	colors = {}, -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
	highlights = {}, -- Override default highlight groups
	ft_highlights = {}, -- Override default highlight groups for specific filetypes
	plugins = { -- Override which plugins highlight groups are loaded
		-- NOTE: Plugins have been omitted for brevity - Please see the plugins section of the README
	},
	styles = { -- Choose from "bold,italic,underline"
		strings = "italic", -- Style that is applied to strings.
		comments = "italic", -- Style that is applied to comments
		keywords = "italic,bold", -- Style that is applied to keywords
		functions = "NONE", -- Style that is applied to functions
		variables = "NONE", -- Style that is applied to variables
		virtual_text = "NONE", -- Style that is applied to virtual text
	},
	options = {
		bold = false, -- Use the themes opinionated bold styles?
		italic = false, -- Use the themes opinionated italic styles?
		underline = false, -- Use the themes opinionated underline styles?
		undercurl = false, -- Use the themes opinionated undercurl styles?
		cursorline = true, -- Use cursorline highlighting?
		transparency = false, -- Use a transparent background?
		terminal_colors = false, -- Use the theme's colors for Neovim's :terminal?
		window_unfocussed_color = false, -- When the window is out of focus, change the normal background?
	},
})

vim.cmd("colorscheme onedarkpro")
