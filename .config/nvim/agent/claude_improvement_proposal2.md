# Neovim 設定 改善提案 — 第2ラウンド

対象: `~/dotfiles/.config/nvim`
作成: 2026-09-09 / Neovim v0.12.5 / lazy.nvim 11.17.5
前提資料: [`claude_improvement_proposal1.md`](./claude_improvement_proposal1.md)（第1ラウンドの詳細）

---

## 0. 現状スナップショット

| 指標 | 第1ラウンド前 | 現在 |
|---|---|---|
| 起動時間（headless, warm） | 約 275ms | **約 88〜95ms**（約 3 倍） |
| プラグイン数（lazy-lock） | 52 | **45** |
| `:checkhealth` の警告 | 多数（deprecation / provider / mason 等） | **haskell-tools のオプション外部ツール未導入のみ**（hoogle / fast-tags / dap 系） |
| 起動時 deprecation 警告 | あり（`vim.lsp.with` 他） | なし |

**第1ラウンドで完了**: A（不具合 A-1〜A-9）/ B（遅延読み込み）/ C-1〜C-4（非推奨 API・mason v2・haskell-tools v10・LspAttach）/ D（oil / lualine / gitsigns / conform / blink.cmp / copilot.lua / render-markdown / tokyonight 一本化 / vim-commentary 削除）/ E（options.lua・keymaps.lua 拡充・which-key）/ D-copilot（Copilot 既定オフ）/ N-1〜N-3 / F-1,F-2,F-4。

---

## 1. 残っている問題・タスク（第1ラウンドの積み残し）

### 1-a. 最優先: 実 GUI での動作確認

移行規模が大きかったため、WezTerm で一度通しで触って確認したい。headless では検証できない項目。

| 対象 | 見るポイント |
|---|---|
| blink.cmp | 補完キーの体感（`Tab`/`S-Tab`/`CR`/`C-y`/`C-space`/`C-n,C-p`/`C-b,C-f`/`C-k`/`C-e`/`C-l`）、スニペット展開、ドキュメント表示、ghost_text |
| conform | `<C-f>` / `:Format` で stylua・black・nimpretty・php-cs-fixer が動くか |
| oil.nvim | defx からの操作感の違い（`-` / `<leader>e` で開く、行編集 + `:w` で反映、`h`/`l`/`q`/`~`） |
| lualine / incline / render-markdown / hlchunk | 見た目・テーマ整合。distracting なら `opts` を調整 |
| which-key | `<leader>` 押下時のポップアップ、`<leader>?`、`<leader>fk` |
| Haskell | `.hs` を開いて HLS が attach するか（v4→v10）、`<leader>h*` |
| clangd | C ファイルで `-std=gnu17` 付き attach、ログにノイズが出ないか |
| CopilotChat | `<leader>cc` で開いて動作するか（copilot.lua は既定オフ、トークンで動く想定） |
| `:Mason` | 開けるか。開いた後 `:checkhealth mason` |

### 1-b. C-5（好み）: LSP キーと 0.11 標準の整理

- `<C-h>` = hover → `K`、`<C-k>` = signature → `<C-s>`（挿入）へ寄せる。
- `gr`（参照）は現在バッファローカルだが、0.11 標準 `gr` プレフィックス（`grr`/`gri`/`grn`/`gra`）と
  前方一致するため **LSP バッファで `gr` 実行に `timeoutlen`(=400ms) の待ち**が入る。
  対応案: `gr`→`grr` に寄せる / 標準キーをそのまま使い独自マッピングを減らす / `timeoutlen` を下げる。
- これを実施すると `keymaps.lua` のウィンドウ移動キー（`<C-h/j/k/l>`）も安全に追加できる。

### 1-c. F の残り

| # | 内容 |
|---|---|
| F-3 | `archive/`（2023 年の packer 遺物）の掃除 — **ユーザー対応予定**。中に追跡済みの `.DS_Store` が 1 件（`archive/vim/nvim/.DS_Store`）。ディレクトリごと消せば一緒に消える |
| F-5 | CopilotChat: `gh` CLI 導入（`brew install gh`）で認証安定。`vim.ui.select` をピッカー連携に（`select = { picker = ... }` か dressing/snacks） |
| F-6 | `brew install hoogle` でローカル Hoogle 検索（haskell-tools） |

### 1-d. 軽微・確認済みだが未対応

- `:checkhealth mason` は mason が `cmd` 遅延のため `:Mason` を一度開いてからでないと "No healthcheck found" になる（実害なし、B 由来の仕様）。
- headless の `:checkhealth haskell-tools` は PATH の関係で HLS を "not found" と誤検出する（`.hs` を開いた状態では正常検出）。

---

## 2. 次の提案のための情報（第2ラウンド候補）

第1ラウンドで手を付けなかった／新たに気づいた改善余地。優先度は仮。

> **実施状況（2026-09-09）**: 2-1 / 2-2 / 2-3 を実施済み。
> - **2-1** ✅ `barbar.lua` 削除（空ファイル）／`lang.lua` 削除＋`conform` に `rust = { "rustfmt" }`
>   （`rust_analyzer` は mason-lspconfig v2 で自動有効化、attach 確認）／
>   `js-ts-svelte.lua` から `vim-svelte`・`html5.vim`・`vim-javascript` を削除（`.svelte` は
>   Neovim 標準 ftdetect + treesitter + `svelte-language-server` で動作確認）。`nvim-ts-autotag` は維持。
>   **`template.nvim` は維持**（`~/.config/nvim/templates/` に `basic_html.tpl` / `tex_report.tpl` / `python/`
>   が実在し使用中）。プラグイン数 45 → 41。
> - **2-2** ✅ `haskell.lua` の `lazy = false` を撤去し `ft` 遅延に（`.hs` を開くと haskell-tools が
>   ロードされることを確認）／`vimtex.lua` に `vim.g.vimtex_syntax_enabled = 0` を追加。
> - **2-3** ✅ `vim.diagnostic.config` を拡張（`severity_sort` / `virtual_lines = { current_line = true }` /
>   nerd-font サインアイコン / `float = { border = "rounded", source = true }`）。
>   `<leader>uh`（inlay hints トグル）/ `<leader>ul`（診断の複数行表示トグル）を追加。
>   `mason.lua` に `ensure_installed`（15 サーバ）を追加＋`vim.lsp.config("lua_ls"/"clangd", …)` で個別設定
>   （`lua_ls`: `checkThirdParty=false`・inlay hints、`clangd`: `--background-index`・`--header-insertion=never` 等）。
>   ※ `~/.config/nvim/lsp/<name>.lua` 方式も試したが、`cmd` など nvim-lspconfig が設定する項目は
>   rtp 順で上書きされてしまうため `vim.lsp.config()` 呼び出しに統一した。

### 2-1. 死んでいる / 古い設定ファイル

| 対象 | 状況 | 提案 |
|---|---|---|
| `lua/plugins/barbar.lua` | 中身が**全部コメントアウト**。`return {}` を返すだけの空ファイル | 削除 |
| `lua/plugins/js-ts-svelte.lua` の `vim-svelte` + `html5.vim` + `vim-javascript` | 旧 VimL トリオ。svelte は treesitter パーサ + `svelte-language-server`（Mason 導入済み）でカバーされる。`nvim-ts-autotag` も別途あり | VimL 3 つを削除、必要なら `ftplugin` で最小設定 |
| `lua/plugins/lang.lua`（`rust.vim`） | `:RustFmt` 等のためだけ。`rust-analyzer` は Mason 導入済み・mason-lspconfig v2 で自動有効化されるはず | conform に `rust`→`rustfmt` を追加して `rust.vim` 削除、or `rustaceanvim` へ（haskell-tools の Rust 版のような立ち位置） |
| `lua/plugins/template.nvim`（glepnir/template.nvim） | メンテ停滞気味。`~/.config/nvim/templates` の実在も要確認 | 使用頻度が低ければ削除し、標準の skeleton autocmd か snippet で代替 |

### 2-2. 起動をさらに詰める

- `lua/plugins/haskell.lua` が `lazy = false`。Haskell を触らない日も毎回ロードされる。
  `ft = { "haskell", "lhaskell", "cabal", "cabalproject" }` だけにできるか検証
  （プラグイン README は「filetype hook を自分で登録するので lazy=false 推奨」とあるが、
  lazy.nvim の `ft` でも `ftdetect` は読まれるので動く可能性が高い）。
- `vimtex` は `ft` 遅延化済み（F-1）。`vim.g.vimtex_syntax_enabled = 0` を明示すると
  treesitter との二重ハイライト注意メッセージが消える。
- `image.nvim` / `render-markdown` / `markdown-preview` が Markdown で 3 つ動く。
  役割は分かれている（画像 / バッファ整形 / ブラウザ）が、重いと感じたら整理候補。

### 2-3. LSP / 診断まわりの底上げ

- **inlay hints**: `vim.lsp.inlay_hint.enable(true)` のトグルキー。Rust/TS/Lua で有用。
- **診断表示**: 0.11+ の `virtual_lines`（複数行の詳細表示）を `vim.diagnostic.config` に。
  現状 `virtual_text = true` のみ。`{ virtual_text = { current_line = true } }` や
  `virtual_lines = { current_line = true }` などの選択肢。
- **診断アイコン**: `vim.diagnostic.config({ signs = { text = { … } } })` でサインカラム記号をカスタム。
- `mason-lspconfig` に **`ensure_installed`** を書いて LSP 導入を宣言的に
  （新マシンで `git clone` → 起動だけで揃う）。現状は `:Mason` 手動管理。
- 各サーバの個別設定が無い（`vim.lsp.config("*")` の capabilities のみ）。
  `lua_ls` の `workspace.checkThirdParty`、`pyright` の型チェックモード、
  `clangd` の `--background-index` 等、`~/.config/nvim/lsp/<name>.lua` or `vim.lsp.config()` で。

### 2-4. プラグイン整理・追加候補

| 目的 | 候補 | 備考 |
|---|---|---|
| 小物プラグインの集約 | `folke/snacks.nvim` or `echasnovski/mini.nvim` | dashboard / bufdelete / notifier / indent / statuscolumn 等をまとめて置換できる。noice + nvim-notify を snacks に寄せる案も |
| `trouble.nvim` の活用 | 現状 `cmd` のみでキーマップ無し | `<leader>xx`（診断）/ `<leader>xX`（バッファ診断）/ `<leader>xs`（symbols）等 |
| `todo-comments` の活用 | ナビ/検索キー無し | `]t`/`[t` 移動、`<leader>ft` = `:TodoTelescope` |
| Git | `gitsigns` に `current_line_blame`、`vim-fugitive` に加えて `:Neogit`（lazygit 派なら不要） | |
| セッション | `folke/persistence.nvim` 等 | ディレクトリ単位で自動復元 |
| textobjects | nvim-treesitter `main` 対応の textobjects（`af`/`if`/`ac`/`ic` 等） | `main` ブランチ移行済みなので導入しやすい |
| surround | `vim-sandwich` 据え置き中。Lua 化なら `mini.surround` / `nvim-surround` | |

### 2-5. フォーマット運用

- `conform.nvim` の **format-on-save** は現在コメントアウト。
  `format_on_save = { lsp_format = "fallback", timeout_ms = 1000 }` を有効にするか、
  `<leader>uf` のようなトグルを用意するか決める。
- `black` → `ruff format` に替えると Python フォーマットが大幅高速化（Black 互換）。
  `ruff` は linter も兼ねるので `nvim-lint` or `ruff` LSP と組み合わせる案。

### 2-6. その他

- `lua/settings/core/keymaps.lua` の `<leader><Space>`（単語検索）は VimL 文字列で
  組んでいる。`vim.fn.expand("<cword>")` を使った Lua 関数に書き換えると読みやすい。
- `.stylua.toml` が無い（`lua/` はハードタブ）。`options.lua` の既定はスペース 4 にしたので、
  Lua だけタブにしたいなら `.stylua.toml`（`indent_type = "Tabs"`）を置くか、
  `after/ftplugin/lua.lua` で `vim.bo.expandtab = false`。方針を決める。
- `nvim-autopairs` は blink.cmp との連携設定なし（blink 側で括弧補完後の挙動を
  調整したい場合は `nvim-autopairs` の `cmp` 連携ではなく blink の設定で）。現状で問題なければ放置。
- カラースキームは tokyonight のみ。`lualine` / `incline` / `render-markdown` / `hlchunk` /
  `which-key` がすべて tokyonight パレットで整合しているか GUI で確認。

### 2-8. 起動最適化 第2弾 … ✅ 実施済み（2026-09-09）

`--startuptime` を再分析して詰めた。**warm 約 80ms → 約 64ms**。

| 対象 | 内容 | 削減 |
|---|---|---|
| `init.lua` の LSP ログガード | `vim.lsp.log.get_filename()` が `vim.lsp` 一式（`util`/`protocol`/`rpc`）を芋づるロードしていた → `vim.fn.stdpath("log").."/lsp.log"` に | ~13ms |
| `nvim-autopairs` | lazy トリガ無し（eager）→ `event = "InsertEnter"` | ~3ms |
| `noice.nvim` | 同上 → `event = "VeryLazy"`（公式推奨） | ~3ms（+ nui/notify を遅延） |
| `nvim-treesitter` の `install()` | `config` 内で同期呼び出し → `vim.schedule()` でクリティカルパス外へ | ~2ms・分散が縮小 |

起動時ロードは **`lazy.nvim` / `nvim-treesitter`（main は eager 必須）/ `nvim-web-devicons` / `oil.nvim`（netrw 置換）/ `tokyonight`（配色）** の 5 つだけになった。いずれも起動時に必要。

**さらに詰めるなら（任意・効果小）**:
- `settings/lazy.lua` の `change_detection = { enabled = false }` … ~2-4ms。ただし plugin spec 編集後に
  `:Lazy reload` or 再起動が必要になる。
- tokyonight のバイトコンパイル / キャッシュ … ~4ms だが割に合わない。
- ここから先は 10ms 未満・実デメリットありなので、64ms で打ち止め推奨。

### 2-7. Org-mode（`nvim-orgmode/orgmode`）… ✅ 導入済み（2026-09-09）

Emacs（`~/.config/doom`）の org 設定と齟齬が出ないように合わせた。

- **`lua/plugins/orgmode.lua` 新規**: `event = "VeryLazy"` + `ft = { "org" }`。初回起動時に
  `org` tree-sitter grammar を自動インストール（`tree-sitter` CLI 済みなので通る）。
- **Doom との対応**:
  | Doom (`config.el`) | orgmode |
  |---|---|
  | `org-directory "~/org/"` + `directory-files-recursively "\.org$"` | `org_agenda_files = { "~/org/**/*.org", "~/org/*.org" }`（40 ファイル解決を確認） |
  | `(sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)")` | 同じ配列 |
  | `org-log-done 'time` / `org-log-into-drawer t` / `org-hide-emphasis-markers t` | `org_log_done="time"` / `org_log_into_drawer="LOGBOOK"` / `org_hide_emphasis_markers=true` |
  | `+org` の `org-startup-folded 'showeverything` | `org_startup_folded="showeverything"` |
  | capture `i`（Inbox→todo.org/Inbox）/ `d`（Daily Task→tasks.org 当日見出し） | `i`（同じ）/ `d`（Emacs の `YYYY/MM/DD (Day)` 形式に合わせた 1 段カスタム日付ツリー） |
  | Doom 既定 `t`/`n`/`j` | `t`（todo.org/Inbox）/ `n`（notes.org/Inbox）/ `j`（journal.org、既存と同じ 年→年-月 月名→年-月-日 曜日 の datetree） |
- **`after/ftplugin/org.lua` 新規**: `conceallevel=2` / `concealcursor="nc"`（orgmode 本体は
  設定しない。emphasis markers・リンク角括弧の非表示に必要）。
- **which-key**: `<leader>o` = Org グループ（`<leader>u` = UI toggle も追加）。
- **キー**: orgmode は `<Leader>o` プレフィックスを使う（`<localleader>` ではない）。
  agenda=`<Leader>oa` / capture=`<Leader>oc`、org バッファ内で `<Leader>ot`=TODO 切替 /
  `<Leader>ois`=SCHEDULED / `<Leader>oid`=DEADLINE / `<Leader>or`=refile /
  `<Leader>oxi`=クロックイン 等（22 個のバッファローカルマップを確認）。
- **Emacs に残す前提の機能**: org-babel 実行、LaTeX プレビュー（`ltximg/`, dvisvgm）、
  `org-download`（画像 D&D → 必要なら `HakonHarnes/img-clip.nvim`）、`org-pomodoro`、
  org-id の一部、複雑なカスタム agenda。閲覧・TODO 操作・capture・軽い編集は Neovim で快適。
- 検証: `.org` を開くと ft=org / TS ハイライト / 折りたたみ、`journal.org`(26KB) をエラーなく開ける、
  起動時間は不変（VeryLazy）。

---

## 3. 推奨着手順（第2ラウンド）

1. ~~**実 GUI 確認**（1-a）~~ … ✅ ユーザー確認済み「今の所大丈夫」
2. ~~**2-1 死にファイル掃除**~~ … ✅ barbar / VimL トリオ / rust.vim（template は使用中のため維持）
3. ~~**2-2 起動をさらに詰める**~~ … ✅ haskell-tools `ft` 遅延 / vimtex syntax 無効
4. ~~**2-3 LSP 底上げ**~~ … ✅ 診断表示強化 / inlay hints トグル / `ensure_installed` / `lua_ls`・`clangd` 個別設定

### これから

5. **C-5**（1-b）— LSP キーと 0.11 標準の整理（`<C-h>`→`K` 等、`gr`→`grr`）＋ ウィンドウ移動キー追加。
6. **2-4 / 2-5** — snacks or mini への集約、trouble/todo キー、format-on-save の方針決め、`black`→`ruff`。
7. **F-5 / F-6**（`brew install gh hoogle`）。
8. **F-3** `archive/` 掃除（ユーザー対応予定）。
