local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	vim.api.nvim_command("packadd packer.nvim")
end

-- local on_file_open = { "BufRead", "BufWinEnter", "BufNewFile" }
local on_file_open = { "BufRead", "BufWinEnter" }

return require("packer").startup({
	function(use)
		-- Packer itself
		use("wbthomason/packer.nvim")

		-- Icons
		use("kyazdani42/nvim-web-devicons")
		use("onsails/lspkind.nvim")

		-- Popup / Plenary
		use({ "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" })

		-- Theme
		use({ "rmehri01/onenord.nvim", config = "require('plugins.theme')" })

		-- Bufferline
		use({
			"akinsho/bufferline.nvim",
			tag = "v2.*",
			after = "onenord.nvim",
			config = "require('plugins.bufferline')",
			events = on_file_open,
		})

		-- Lualine
		use({
			"nvim-lualine/lualine.nvim",
			after = "onenord.nvim",
			events = on_file_open,
			config = "require('plugins.lualine')",
		})

		-- Zen mode
		use({ "folke/zen-mode.nvim", after = "twilight.nvim", config = "require('plugins.zen_mode')" })

		-- Better Escape
		use({
			"max397574/better-escape.nvim",
			events = "InsertEnter",
			config = function()
				require("better_escape").setup()
			end,
		})

		-- Missing directories
		use({ "jghauser/mkdir.nvim" })

		-- Gitsigns
		use({ "lewis6991/gitsigns.nvim", config = "require('plugins.gitsigns')" })

		-- Indent BlankLine
		use({
			"lukas-reineke/indent-blankline.nvim",
			events = on_file_open,
			config = "require('plugins.indent_blankline')",
		})

		-- Treesitter
		use({ "nvim-treesitter/nvim-treesitter", events = on_file_open, config = "require('plugins.treesitter')" })

		-- TS context commenting
		use({ "JoosepAlviste/nvim-ts-context-commentstring", events = on_file_open })

		-- TS Context
		use({
			"lewis6991/nvim-treesitter-context",
			events = on_file_open,
			config = function()
				require("treesitter-context").setup()
			end,
		})

		-- TS Autotag
		use({ "windwp/nvim-ts-autotag", events = on_file_open, after = "nvim-treesitter" })

		-- Twilight
		use({ "folke/twilight.nvim", after = "nvim-treesitter", config = "require('plugins.twilight')" })

		-- Hop (like easymotion)
		use({
			"phaazon/hop.nvim",
			branch = "v1", -- optional but strongly recommended
			config = function()
				require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
			end,
		})

		-- Comment
		use({
			"numToStr/Comment.nvim",
			events = on_file_open,
			config = function()
				require("Comment").setup()
			end,
		})

		-- Telescope
		use({ "nvim-telescope/telescope.nvim", config = "require('plugins.telescope')" })

		-- Telescope fzf-native
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

		-- Telescope filebrowser
		use({ "nvim-telescope/telescope-file-browser.nvim" })

		-- Autopairs
		use({ "windwp/nvim-autopairs", events = on_file_open, config = "require('plugins.autopairs')" })

		-- Null-ls
		use({ "jose-elias-alvarez/null-ls.nvim", events = on_file_open, config = "require('plugins.null_ls')" })

		-- Lsp
		use("williamboman/nvim-lsp-installer")
		use({ "neovim/nvim-lspconfig", after = "nvim-lsp-installer", config = "require('plugins.lspconfig')" })

		-- Snippets
		use({ "L3MON4D3/LuaSnip", config = "require('plugins.luasnip')" })
		use("rafamadriz/friendly-snippets")

		-- Cmp
		use("hrsh7th/cmp-nvim-lsp")
		use("hrsh7th/cmp-buffer")
		use("hrsh7th/cmp-path")
		use("hrsh7th/cmp-cmdline")
		use({ "hrsh7th/nvim-cmp", config = "require('plugins.cmp')" })
		use("saadparwaiz1/cmp_luasnip")

		-- Markdown preview
		use({
			"iamcco/markdown-preview.nvim",
			run = function()
				vim.fn["mkdp#util#install"]()
			end,
			config = function()
				vim.cmd("let g:mkdp_auto_start = 1")
			end,
		})

		-- Automatically set up your configuration after cloning packer.nvim
		-- Put this at the end after all plugins
		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = function()
				return require("packer.util").float({ border = "single" })
			end,
		},
	},
})
