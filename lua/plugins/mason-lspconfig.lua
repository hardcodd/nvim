return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),

				on_attach = function(client, bufnr)
					vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

					local opts = { noremap = true, silent = true }
					local function map(...)
						vim.api.nvim_buf_set_keymap(bufnr, ...)
					end

					map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
					map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
					map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
					map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
					map("n", "<space>s", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
					map("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
					map("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
					map("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
					map("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
					map("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
					map("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
					map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
					map("n", "<space>fl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
					map("n", "dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
					map("n", "dn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
				end,
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			vim.lsp.config("pyright", {
				on_attach = function(client, bufnr)
					client.server_capabilities.hoverProvider = nil
					client.server_capabilities.definitionProvider = nil
					client.server_capabilities.typeDefinitionProvider = nil
					client.server_capabilities.implementationProvider = nil
					client.server_capabilities.referencesProvider = nil
				end,
			})
		end,
	},

	{
		"mason-org/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				automatic_enable = true,
				ensure_installed = {
					"jedi_language_server",
					"vimls",
					"emmet_ls",
					"stylelint_lsp",
					"eslint",
					"ts_ls",
					"lua_ls",
					"clangd",
					"pyright",
					"jsonls",
					"html",
					"cssls",
					"bashls",
          "ruff"
				},
			})
		end,
	},
}
