vim.opt.list = true
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup({
	indentLine_enabled = 1,
	char = "▏",
	show_end_of_line = true,
	indent_blankline_use_treesitter = true,
	indent_blankline_use_treesitter_scope = true,
	filetype_exclude = {
		"help",
		"terminal",
		"alpha",
		"packer",
		"lspinfo",
		"TelescopePrompt",
		"TelescopeResults",
		"lsp-installer",
		"",
	},
	buftype_exclude = {
		"terminal",
	},
})
