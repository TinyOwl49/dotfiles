local toggleterm = require("toggleterm")
toggleterm.setup({ close_on_exit = false })

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>t", "<ESC>:ToggleTerm direction=float<CR>", opts)
vim.keymap.set("n", "<leader>th", "<ESC>:ToggleTerm direction=horizontal<CR>", opts)
vim.keymap.set("n", "<leader>tv", "<ESC>:ToggleTerm direction=vertical<CR>", opts)
vim.keymap.set("n", "<leader>tt", "<ESC>:ToggleTerm direction=tab<CR>", opts)
vim.keymap.set("n", "<leader>tf", "<ESC>:ToggleTerm direction=float<CR>", opts)

vim.api.nvim_create_user_command("T", ":0TermExec cmd=<q-args>", { nargs = "?" })
