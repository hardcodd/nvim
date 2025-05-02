return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "  ",
				layout_strategy = "flex",
				layout_config = {
					vertical = {
						width = 0.9,
						height = 0.9,
						preview_height = 0.5,
					},
					horizontal = {
						width = 0.9,
						height = 0.9,
						preview_width = 0.5,
					},
				},
				mappings = {
					["n"] = { ["q"] = require("telescope.actions").close },
					["i"] = {
						["jk"] = require("telescope.actions").close,
						["<PageUp>"] = require("telescope.actions").preview_scrolling_up,
						["<PageDown>"] = require("telescope.actions").preview_scrolling_down,
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
					},
				},
				file_ignore_patterns = {
					-- version control
					"/.git",
					"/.hg",
					"/.svn",
					"node_modules",

					-- django / python
					"__pycache__",
					"migrations",
					"/venv",
					"/.venv",
					"/env",
					"media/",
					"cache/",
					"static/",
					"%.sqlite3",
					"%.db",

					-- images
					"%.jpg",
					"%.jpeg",
					"%.png",
					"%.gif",
					"%.webp",
					"%.svg",
					"%.ico",
					"%.tiff",
					"%.bmp",
					"%.webp",
					"%.heic",
					"%.heif",
					"%.avif",

					-- archives
					"%.zip",
					"%.tar",
					"%.gz",
					"%.bz2",
					"%.xz",
					"%.7z",
					"%.rar",
					"%.tar.gz",
					"%.tar.bz2",
					"%.tar.xz",

					-- os files
					"%.app",
					"%.exe",
					"%.msi",
					"%.dmg",
					"%.deb",
					"%.rpm",
					"%.exe",
					"%.dll",

					-- file browser. Win / MacOs / Linux
					".DS_Store",
					"Thumbs.db",
					".Trashes",
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

		require("telescope").load_extension("fzf")
		require("telescope").load_extension("file_browser")
	end,
}
