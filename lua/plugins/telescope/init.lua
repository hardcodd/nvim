require("telescope").setup({
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "descending",
		layout_strategy = "horizontal",
		layout_config = {
			width = 0.75,
			preview_cutoff = 120,
			horizontal = {
				preview_width = function(_, cols, _)
					if cols < 120 then
						return math.floor(cols * 0.5)
					end
					return math.floor(cols * 0.6)
				end,
				mirror = false,
			},
			vertical = { mirror = false },
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--glob=!.git/",
		},
		-- config_key = value,
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
				["<A-k>"] = "preview_scrolling_up",
				["<A-j>"] = "preview_scrolling_down",
				["jk"] = "close",
				["<esc>"] = "close",
			},
		},
		file_ignore_patterns = {
			"^.git/*",
			"plugin/packer_compiled.lua",
			"__pycache__",
			"cache/*",
			"node_modules/*",
			"media/*",
			"venv/*",
			"dist/*",
			"-- - *.png$",
			"-- - *.jpg$",
			"-- - *.jpeg$",
			"-- - *.gif$",
			"-- - *.webp$",
			"-- - *.ico$",
			"-- - *.ttf$",
			"-- - *.otf$",
			"-- - *.eot$",
			"-- - *.woff$",
			"-- - *.woff2$",
		},
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		live_grep = {
			--don't include the filename in the search results
			only_sort_text = true,
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
		},
	},
})
