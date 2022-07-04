require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = "all",

	sync_install = false, -- (only applied to `ensure_installed`)
	-- ignore_install = { "javascript" },
	highlight = {
		enable = true,
		-- disable = { "c", "rust" },
		additional_vim_regex_highlighting = false, -- NEVER EVER SET IT TO TRUE!!!
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
		config = {
			-- Languages that have a single comment style
			typescript = "// %s",
			css = "/* %s */",
			scss = "/* %s */",
			html = "<!-- %s -->",
			svelte = "<!-- %s -->",
			vue = "<!-- %s -->",
			json = "",
		},
	},
	indent = { enable = true, disable = { "yaml", "python" } },
	autotag = {
		enable = true,
	},
})
