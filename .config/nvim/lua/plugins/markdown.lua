return {
	{
		"iamcco/markdown-preview.nvim",
		-- lazy.nvim のキーは build / init（run / setup は packer 用で無効だった）。
		-- install.sh はプリビルドバイナリを app/bin へ取得する。ft 遅延でも確実に走るよう
		-- Lua 関数(mkdp#util#install)ではなくシェルで直接叩く。
		build = "cd app && bash install.sh",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},
	{
		-- バッファ内で見出し・表・コードブロック・チェックボックス等を整形表示。
		-- markdown-preview（ブラウザ）とは別物で、image.nvim とも併用可。
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},
}
