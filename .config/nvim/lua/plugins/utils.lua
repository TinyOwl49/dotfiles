return {
	{
		-- ステータスライン（vim-airline から移行。Lua 製で軽くテーマ連携も楽）
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				theme = "tokyonight",
				globalstatus = true,
				section_separators = "",
				component_separators = "",
			},
		},
	},
	{
		-- ファイル名をウィンドウごとに表示する
		"b0o/incline.nvim",
		event = "VeryLazy",
		opts = {
			hide = { cursorline = true },
			window = { margin = { vertical = 0 } },
		},
	},
	{
		-- gitの操作
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "Gclog", "Gllog", "GBrowse", "GMove", "GRename", "GDelete" },
	},
	{
		-- git 差分表示（vim-gitgutter から移行。非同期・hunk 操作・blame）
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(buf)
				local gs = require("gitsigns")
				local map = function(l, r, desc)
					vim.keymap.set("n", l, r, { buffer = buf, silent = true, desc = desc })
				end
				map("]c", function() gs.nav_hunk("next") end, "Next hunk")
				map("[c", function() gs.nav_hunk("prev") end, "Prev hunk")
				map("<leader>hs", gs.stage_hunk, "Stage hunk")
				map("<leader>hr", gs.reset_hunk, "Reset hunk")
				map("<leader>hp", gs.preview_hunk, "Preview hunk")
				map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
			end,
		},
	},
	{
		-- yankを光らせる
		"machakann/vim-highlightedyank",
		event = "VeryLazy",
	},
	-- vim-commentary は削除（Neovim 0.10+ 標準の gc / gcc / gc{motion} で十分）
	-- registers.nvim も削除（tversteeg/registers.nvim が GitHub から消滅・更新不可のため）
	{
		-- テキストをサンドウィッチする
		"machakann/vim-sandwich",
		event = "VeryLazy",
	},
	{
		-- ドキュメントを日本語に
		"vim-jp/vimdoc-ja",
		event = "VeryLazy",
	},
	{
		-- コメントを目立たせたり検索したりできる
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("todo-comments").setup({})
		end,
	},
	{
		-- neovimの起動時間を表示
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
	},

	{
		-- テンプレートを作成&読み込み
		"glepnir/template.nvim",
		cmd = { "Template", "TemProject" },
		config = function()
			require("template").setup({
				-- config in there
				temp_dir = "~/.config/nvim/templates",
			})
		end,
	},
	{
		-- インデントガイド
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("hlchunk").setup({})
		end,
	},
}
