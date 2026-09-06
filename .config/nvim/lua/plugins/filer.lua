-- ファイラ: oil.nvim（defx.nvim から移行）
-- oil はディレクトリを「バッファ」として開き、行の編集＋ :w で作成/削除/rename を行う。
return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false, -- netrw の置き換えも兼ねるため起動時に読む
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
			{ "<leader>e", "<cmd>Oil<CR>", desc = "Open file explorer (oil)" },
		},
		opts = {
			default_file_explorer = true, -- netrw を置き換える
			view_options = {
				show_hidden = true,
			},
			-- defx 相当のキー感覚に寄せる
			keymaps = {
				["q"] = "actions.close",
				["h"] = "actions.parent",
				["l"] = "actions.select",
				["<C-l>"] = "actions.refresh",
				["~"] = "actions.cd",
			},
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		cmd = "Trouble",
	},
}
