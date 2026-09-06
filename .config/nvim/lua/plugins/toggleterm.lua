-- lua製のターミナル

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec", "T" },
	keys = {
		{ "<leader>t",  "<cmd>ToggleTerm direction=float<CR>",      desc = "Terminal (float)" },
		{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal (horizontal)" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "Terminal (vertical)" },
		{ "<leader>tt", "<cmd>ToggleTerm direction=tab<CR>",        desc = "Terminal (tab)" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      desc = "Terminal (float)" },
	},
	config = function()
		require("toggleterm").setup({ close_on_exit = false })

		vim.api.nvim_create_user_command("T", ":0TermExec cmd=<q-args>", { nargs = "?" })
	end,
}
