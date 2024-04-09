vim.api.nvim_set_keymap("n", "<F5>", ":DapContinue<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":DapStepOver<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":DapStepInto<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":DapStepOut<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>b", ":DapToggleBreakpoint<CR>", { silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>B",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>',
	{ silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>lp",
	':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',
	{ silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>dr", ':lua require("dap").repl.open()<CR>', { silent = true })
vim.api.nvim_set_keymap("n", "<leader>dl", ':lua require("dap").run_last()<CR>', { silent = true })

-- local dap = require("dap")
-- dap.configurations.python = {
-- 	{
-- 		type = "python",
-- 		request = "launch",
-- 		name = "Launch file",
-- 		program = "${file}",
-- 		pythonPath = function()
-- 			return "${env:CONDA_PREFIX}/bin/python"
-- 		end,
-- 	},
-- }
