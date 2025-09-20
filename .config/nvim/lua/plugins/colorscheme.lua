return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		opts = { style = "dark" },
		-- config = function()
		-- 	require('onedark').load()
		-- end
	},
	{
		"folke/tokyonight.nvim",
		opts = { style = "storm" },
		config = function()
			require('tokyonight').load()
		end
	},
}
