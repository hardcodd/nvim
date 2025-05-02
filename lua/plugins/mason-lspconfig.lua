return {
	"williamboman/mason.nvim",
	"neovim/nvim-lspconfig",
	{

		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"cssls",
					"html",
					"jsonls",
					"jedi_language_server",
					"vimls",
					"emmet_ls",
					"lua_ls",
					"stylelint_lsp",
					"eslint",
					"ts_ls",
				},
				automatic_installation = true,
			})

			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					local capabilities = require("cmp_nvim_lsp").default_capabilities()
					local on_attach = function(client, bufnr)
						-- Enable completion triggered by <c-x><c-o>
						vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

						-- Mappings.
						local opts = { noremap = true, silent = true }
						local function buf_set_keymap(...)
							vim.api.nvim_buf_set_keymap(bufnr, ...)
						end
						buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
						buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
						buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
						buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
						buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
						buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
						buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
						buf_set_keymap(
							"n",
							"<space>wl",
							"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
							opts
						)
						buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
						buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
						buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
						buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
						buf_set_keymap("n", "<space>fl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
						buf_set_keymap("n", "dp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
						buf_set_keymap("n", "dn", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
					end
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						on_attach = on_attach,
					})
				end,
				-- Next, you can provide a dedicated handler for specific servers.
				-- For example, a handler override for the `rust_analyzer`:
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					})
				end,
				["pyright"] = function()
					local lspconfig = require("lspconfig")
					local capabilities = require("cmp_nvim_lsp").default_capabilities()
					lspconfig.pyright.setup({
						on_attach = function(client, bufnr)
							client.server_capabilities.hoverProvider = nil
							client.server_capabilities.definitionProvider = nil
							client.server_capabilities.typeDefinitionProvider = nil
							client.server_capabilities.implementationProvider = nil
							client.server_capabilities.referencesProvider = nil
						end,
						capabilities = capabilities,
					})
				end,
			})
		end,
	},
}
