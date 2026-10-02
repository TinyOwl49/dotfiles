vim.g.mapleader = " "

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param desc string|nil
---@param opts table|nil
local function map(mode, lhs, rhs, desc, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true, desc = desc }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- 既存
map("n", "mp", '"0p', "ヤンクレジスタ(0)から貼り付け", { silent = false })
map(
	"n",
	"<leader><Space>",
	"\"zyiw:let @/ = '<' . @z . '>'<CR>:set hlsearch<CR>",
	"カーソル下の単語を完全一致で検索"
)
map("n", "<leader>q", "<ESC>:nohlsearch<CR>", "検索ハイライトを消す")
map("t", "<ESC>", "<C-\\><C-n>", "端末: ノーマルモードへ抜ける")

-- 編集補助 
map("x", "<", "<gv", "インデント減（選択維持）")
map("x", ">", ">gv", "インデント増（選択維持）")
map("n", "J", "mzJ`z", "下の行を連結（カーソル固定）")
map("x", "J", ":m '>+1<CR>gv=gv", "選択行を下へ")
map("x", "K", ":m '<-2<CR>gv=gv", "選択行を上へ")

-- 検索・スクロール後に画面中央へ 
map("n", "n", "nzzzv", "次の検索結果（中央）")
map("n", "N", "Nzzzv", "前の検索結果（中央）")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- レジスタを汚さない
map("x", "<leader>p", [["_dP]], "ヤンクを保持して貼り付け")
map({ "n", "x" }, "<leader>d", [["_d]], "ブラックホールへ削除")
map("n", "x", [["_x]], "1文字削除（レジスタ非汚染）")

-- 保存・バッファ 
map("n", "<leader>bs", "<cmd>write<CR>", "バッファを保存")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "バッファを閉じる")
map("n", "<S-l>", "<cmd>bnext<CR>", "次のバッファ")
map("n", "<S-h>", "<cmd>bprevious<CR>", "前のバッファ")
