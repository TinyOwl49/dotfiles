return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				-- null_ls.builtins.diagnostics.eslint,
				null_ls.builtins.completion.spell,
				null_ls.builtins.formatting.nimpretty,
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.phpcsfixer,
			},
		})
	end,
}
