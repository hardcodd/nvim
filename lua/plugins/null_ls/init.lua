local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	sources = {
		null_ls.builtins.code_actions.gitsigns,

		diagnostics.editorconfig_checker,
		diagnostics.flake8,
		-- diagnostics.pydocstyle,
		formatting.autopep8,
		formatting.isort,

		formatting.stylua,

		-- formatting.fixjson,
		-- formatting.deno_fmt,
		-- formatting.djhtml,
		-- formatting.djlint,
		-- formatting.markdownlint,
		-- formatting.mdformat,

		formatting.stylelint,

		-- formatting.prettier,
		formatting.prettierd,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						bufnr = bufnr,
						---@diagnostic disable-next-line: redefined-local
						filter = function(client)
							return client.name == "null-ls"
						end,
					})
				end,
			})
		end
	end,
})
