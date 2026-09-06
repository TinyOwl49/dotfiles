-- ファイラ
return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false, -- netrw の置き換えをするので起動時に読む
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
			{ "<leader>e", "<cmd>Oil<CR>", desc = "Open file explorer (oil)" },
		},
		opts = {
			default_file_explorer = true, -- netrw を置き換える
			view_options = {
				show_hidden = true,
			},
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
