return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		opts = { style = "dark" },
		config = function()
			require('onedark').load()
		end
	},
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = true,
	-- 	opts = { style = "moon" },
	-- },
	--
}
