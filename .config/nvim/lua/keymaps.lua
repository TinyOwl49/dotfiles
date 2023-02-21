vim.g.mapleader = " "

local opts1 = { noremap = true, silent = true }
local opts2 = { noremap = true, silent = false }
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>", opts2)
vim.keymap.set("n", "<C-s>", "<ESC>:w<CR>", opts2)
vim.keymap.set("n", "mp", '"0p', opts2)

vim.keymap.set("n", "<leader><Space>", "\"zyiw:let @/ = '<' . @z . '>'<CR>:set hlsearch<CR>", opts1)
vim.keymap.set("n", "<leader>q", "<ESC>:nohlsearch<CR>", opts1)
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", opts1)
