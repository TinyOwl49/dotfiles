-- 配色は tokyonight に一本化（onedark は実質未使用だったので削除）
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
