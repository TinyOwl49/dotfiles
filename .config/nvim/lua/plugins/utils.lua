return {
	{
		-- ステータスバーをかっこよくする
		"vim-airline/vim-airline",
	},
	{
		-- ファイル名をウィンドウごとに表示する
		"b0o/incline.nvim",
	},
	{
		-- airlineのcolorscheme
		"vim-airline/vim-airline-themes",
	},
	{
		-- gitの操作
		"tpope/vim-fugitive",
	},
	{
		--git差分の表示
		"airblade/vim-gitgutter",
	},
	{
		-- yankを光らせる
		"machakann/vim-highlightedyank",
	},
	{
		-- discord rich presence
		"andweeb/presence.nvim",
	},
	{
		-- コメントアウトを便利にする
		"tpope/vim-commentary",
	},
	{
		-- レギストリを表示
		"tversteeg/registers.nvim",
	},
	{
		-- テキストをサンドウィッチする
		"machakann/vim-sandwich",
	},
	{
		-- ドキュメントを日本語に
		"vim-jp/vimdoc-ja",
	},
	{
		-- インデントをわかりやすく表示
		"lukas-reineke/indent-blankline.nvim",
	},
	{
		-- コメントを目立たせたり検索したりできる
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	},
	{
		-- neovimの起動時間を表示
		"dstein64/vim-startuptime",
	},

	{
		-- テンプレートを作成&読み込み
		"glepnir/template.nvim",
		cmd = { "Template", "TemProject" },
		config = function()
			require("template").setup({
				-- config in there
				temp_dir = '~/.config/nvim/templates'
			})
		end,
	},
}
