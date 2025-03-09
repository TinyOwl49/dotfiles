-- require("mason-lspconfig").setup_handlers({
-- 	function(server)
-- 		local opt = {
-- 			on_attach = function(client, bufnr)
-- 				-- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
-- 			end,
-- 			capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
-- 		}
-- 		require("lspconfig")[server].setup(opt)
-- 	end,
-- })
-- vim.diagnostic.config({
-- 	virtual_text = false,
-- 	underline = true,
-- })

return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			underline = true,
			virtual_text = true,
		})

		-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { separator = true })
		-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { separator = true })

		local opts = { noremap = true, silent = true }
		vim.keymap.set("n", "<C-h>", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-e>", vim.diagnostic.open_float, opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
		vim.keymap.set("n", "gN", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
		vim.keymap.set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
		vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
		vim.keymap.set("n", "[p", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
		vim.keymap.set("n", "[n", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
		vim.keymap.set("n", "gn", "<cmd>bnext<CR>", opts)
		vim.keymap.set("n", "gp", "<cmd>bprevious<CR>", opts)

		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	buffer = buffer,
		-- 	callback = function()
		-- 		if vim.lsp.buf.server_ready() then
		-- 			vim.lsp.buf.format({ async = true })
		-- 		end
		-- 	end,
		-- })
		vim.api.nvim_create_user_command("Format", function()
			vim.lsp.buf.format({ async = true })
		end, {})

		vim.keymap.set("n", "<leader>ff", "<ESC>:Format<CR>", { noremap = true, silent = true })

	end
}
