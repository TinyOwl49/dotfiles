return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- 他プラグインより先にロード
		opts = { style = "storm" },
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
}
