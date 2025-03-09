return {
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
		ft = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"svelte",
			"vue",
			"tsx",
			"jsx",
			"rescript",
		},
	}, -- ReactとかSvelteのタグを自動で閉じてくれる
	{
		"evanleck/vim-svelte",
		dependencies = {
			"othree/html5.vim",
			"pangloss/vim-javascript",
		},
		config = function()
			vim.g.svelte_preprocessors = { "typescript" }
		end,
	},
}
