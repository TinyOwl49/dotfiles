-- orgmode 本体は conceallevel を設定しないので、ここで有効化する。
-- org_hide_emphasis_markers = true と リンク角括弧の非表示にはこれが必要。
-- （Doom Emacs の見た目に合わせている）
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "nc" -- 挿入/ビジュアル中はマーカーを表示して編集しやすく
