local opt = vim.opt

-- 文字コード
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.ambiwidth = "single"

-- インデント（スペース 4）
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

-- 検索
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true -- 小文字だけなら大小無視
opt.smartcase = true -- 大文字を含むと大小区別

-- UI / 表示
opt.number = true
opt.wrap = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true -- 現在行をハイライト
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true -- 縦分割は右へ
opt.splitbelow = true -- 横分割は下へ
opt.pumheight = 12 -- 補完メニューの最大行数
opt.showmode = false
opt.list = true
opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }

-- 編集・ファイル
opt.clipboard = "unnamedplus"
opt.undofile = true -- 永続 undo
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.mouse = "a" -- 全モードでマウス有効

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
