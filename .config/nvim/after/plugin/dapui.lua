vim.api.nvim_set_keymap("n", "<leader>d", ':lua require("dapui").toggle()<CR>', {})

require("dapui").setup({
	icons = { expanded = "", collapsed = "" },
	layouts = {
		{
			elements = {
				{ id = "watches",     size = 0.20 },
				{ id = "stacks",      size = 0.20 },
				{ id = "breakpoints", size = 0.20 },
				{ id = "scopes",      size = 0.40 },
			},
			size = 64,
			position = "right",
		},
		{
			elements = {
				"repl",
				"console",
			},
			size = 0.20,
			position = "bottom",
		},
	},
})
