return {
	"L3MON4D3/LuaSnip",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "v2.*",
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")

		require("luasnip.loaders.from_vscode").lazy_load()
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

		ls.filetype_extend("htmldjango", { "djangohtml" })
		ls.filetype_extend("htmldjango", { "html" })
		ls.filetype_extend("liquid", { "html" })
		ls.filetype_extend("python", { "django" })

		ls.config.set_config({
			-- This tells LuaSnip to remember to keep around the last snippet.
			-- You can jump back into it even if you move outside of the selection
			history = true,

			-- This one is cool cause if you have dynamic snippets, it updates as you type!
			updateevents = "TextChanged,TextChangedI",

			-- Autosnippets:
			enable_autosnippets = true,
		})
	end,
}
