return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.2", -- v0.2.x で previewer が nvim-treesitter main / Neovim core API に対応
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "Telescope",
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "全文検索 (live grep)" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "バッファ一覧" },
		{ "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "ヘルプ検索" },
		{ "<leader>fk", "<cmd>Telescope keymaps<cr>",    desc = "キーマップ検索" },
	},
}
