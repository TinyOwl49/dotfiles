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
	-- vim-svelte / html5.vim / vim-javascript（旧 VimL）は削除。
	-- .svelte は Neovim 標準の filetype 判定 + treesitter(svelte) + svelte-language-server で対応。
}
