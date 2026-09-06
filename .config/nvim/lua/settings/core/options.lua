local opt = vim.opt

-- 文字コード
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.ambiwidth = "single" -- East Asian 曖昧幅を単一に

-- インデント（スペース 4。言語ごとの差は ftplugin / フォーマッタ側で調整）
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
opt.termguicolors = true -- WezTerm では自動 true だが明示
opt.signcolumn = "yes" -- 診断 / gitsigns で幅がガタつかない
opt.cursorline = true -- 現在行をハイライト
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true -- 縦分割は右へ
opt.splitbelow = true -- 横分割は下へ
opt.pumheight = 12 -- 補完メニューの最大行数
opt.showmode = false -- モード表示は lualine に任せる
opt.list = true
opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }

-- 編集・ファイル
opt.clipboard = "unnamedplus"
opt.undofile = true -- 永続 undo
opt.swapfile = false
opt.updatetime = 250 -- CursorHold 系の反応を速く
opt.timeoutlen = 400 -- which-key ポップアップ / マッピング待ちの体感改善
opt.mouse = "a" -- 全モードでマウス有効

-- 使っていない言語プロバイダを無効化（checkhealth の警告抑制・不要な host 起動の防止）
-- defx.nvim を oil.nvim に置き換えたので python3 プロバイダも不要になった。
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
