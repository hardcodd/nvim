local lsp_installer = require("nvim-lsp-installer")
local lspconfig = require("lspconfig")

lsp_installer.setup({
	automatic_installation = true,
})

local servers = {
	"html",
	"cssls",
	"tsserver",
	"pyright",
	"sumneko_lua",
	"eslint",
	"vuels",
	"jsonls",
}

local diagnostics = require("diagnostics")

vim.diagnostic.config({
	virtual_text = diagnostics.virtual_text,
	signs = diagnostics.signs,
	underline = diagnostics.underline,
	update_in_insert = diagnostics.update_in_insert,
	severity_sort = diagnostics.severity_sort,
	float = diagnostics.float,
})

local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, diagnostics.float),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, diagnostics.float),
}

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
	-- Disable default formatters
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
end

for _, server in ipairs(servers) do
	if "sumneko_lua" == server then
		lspconfig[server].setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
	else
		lspconfig[server].setup({
			capabilities = capabilities,
			handlers = handlers,
			on_attach = on_attach,
		})
	end
end
