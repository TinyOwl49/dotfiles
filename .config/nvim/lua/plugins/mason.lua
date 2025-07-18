return {
	{
		"williamboman/mason.nvim",
		version = "^1.0.0",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		version = "^1.0.0",
		config = function()
			require("mason-lspconfig").setup_handlers({
				function(server)
					local opt = {
						on_attach = function(client, bufnr)
							-- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
						end,
						capabilities = require("cmp_nvim_lsp").default_capabilities(
							vim.lsp.protocol.make_client_capabilities()
						),
					}
					require("lspconfig")[server].setup(opt)
				end,
			})
		end,
	},
}
