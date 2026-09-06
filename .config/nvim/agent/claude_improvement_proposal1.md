# Neovim 設定 改善提案

対象: `~/dotfiles/.config/nvim`
調査日: 2026-09-06 / Neovim v0.12.5 / lazy.nvim 11.17.5
参照: `checkhealth_result.txt`、`nvim --startuptime`、各 `lua/plugins/*.lua`

計測した起動時間（headless）: **調査時 約 275ms → 対応後 約 95〜105ms**（B の遅延読み込みで約 2.7 倍高速化）。

---

## 進捗サマリ（2026-09-06 時点）

### 提案書作成前に対応済み（Neovim 0.11 → 0.12 アップグレード起因の不具合）

| 項目 | 内容 | 状態 |
|---|---|---|
| treesitter | `nvim-treesitter` を `master`（凍結）→ `main` ブランチへ移行。`tree-sitter-cli` を `brew install tree-sitter-cli` で導入。highlight/indent は FileType autocmd で自前有効化。Markdown を開くと出ていた `attempt to call method 'range'` を解消 | ✅ |
| telescope | `tag = '0.1.8'` → `tag = 'v0.2.2'`。previewer の `ft_to_lang`（nvim-treesitter master API）依存を解消。プレビュー時の `attempt to call field 'ft_to_lang'` を解消 | ✅ |
| deprecation (C-1) | `lspconfig.lua` の `vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, …)` → `vim.diagnostic.config()`。`vim.diagnostic.goto_prev/next` → `vim.diagnostic.jump({ count = … })`。起動時 `vim.lsp.with() is deprecated` 警告を解消 | ✅ |

### 提案書ベースの対応

| セクション | 状態 | メモ |
|---|---|---|
| **A**（不具合・死に設定） | ✅ **A-1〜A-9 すべて完了** | 詳細は下の「A 実施状況」ブロック。A-8（LSP ログ）も 2026-09-09 対応済み |
| **B**（遅延読み込み） | ✅ **B-1〜B-4 すべて完了** | 起動 275ms→~100ms。詳細は「B 実施状況」ブロック |
| **C**（非推奨 API・古い書き方） | ✅ C-1〜C-4 完了 | C-2（haskell-tools v10）/ C-3（mason v2）/ C-4（LspAttach）済み。C-5 は好みのため未対応 |
| **D**（プラグイン代替案） | ✅ **主要項目すべて完了** | defx→oil / airline→lualine / gitgutter→gitsigns / commentary 削除 / none-ls→conform / nvim-cmp→blink.cmp / copilot.vim→copilot.lua / onedark 削除 / render-markdown 追加。vim-sandwich・template・registers は据え置き |
| **E**（options / keymaps 拡充） | ✅ 完了 | which-key + desc / options.lua / keymaps.lua すべて拡充済み（ウィンドウ移動キーのみ C-5 待ちで見送り） |
| **F**（小ネタ） | ◐ 大半完了 | colorscheme priority ✅ / noice cmp override 削除 ✅ / **F-1 vimtex `ft` 遅延 ✅** / **F-2 `.DS_Store` gitignore ✅** / **F-4 `python3_host_prog` 削除 ✅** / cmp Tab フォールバック（blink 側で対応済み）。F-3 `archive/` 掃除（ユーザー対応予定）・F-5/F-6 は未 |

### 対応中に新たに判明した事項

| # | 内容 | 状態 |
|---|---|---|
| N-1 | `registers.nvim`（`tversteeg/registers.nvim`）の GitHub リポジトリが **404（削除済み）** | ✅ `utils.lua` から削除＋`:Lazy clean` 済み |
| N-2 | （旧）`cmp.lua` の `opts`/`config` 併存で lazydev 補完ソースが無効だった問題 | ✅ D の blink.cmp 移行で解消（`sources.providers.lazydev` で明示接続） |
| N-3 | A-8 の LSP ログ 100MB は「ログレベルではなく **サーバ stderr（clangd の compile DB 不在ノイズ ~53k 行・Copilot npx ノイズ）**」が原因と判明 | ✅ 対応済み（rm ＋ サイズガード ＋ clangd `compile_flags.txt` / グローバル `config.yaml`） |

---

## A. 今すぐ直したい不具合・死んでいる設定（優先度: 高）

> **実施状況（2026-09-06）**: A-8 以外はすべて適用済み。
> - A-1 ✅ `markdown.lua` を `build = "cd app && bash install.sh"` + `init` に修正。
>   プリビルドバイナリ（`app/bin/markdown-preview-macos-arm64`, 51MB）取得済み。
>   ※ `mkdp#util#install()` を Lua 関数で呼ぶ形は ft 遅延時に `E117` で失敗するためシェル直叩きに。
> - A-2 ✅ `incline.nvim` に `event="VeryLazy"` + `opts` を付与して有効化。
> - A-3 ✅ `indent-blankline.nvim` を削除（lazy が clean 済み）。インデントガイドは hlchunk のみ。
> - A-4 ✅ `cmp.lua` の `formatting`（lspkind）を有効化（`mode = "symbol_text"`）。
> - A-5 ✅ `cmp.lua` の `{ name = "copilot" }` ソースを削除。
> - A-6 ✅ CopilotChat `FixDiagnostic` のマッピングを `<leader>cd` → `<leader>cD` に。
> - A-7 ✅ `:MasonUninstall nimlsp` 実行。Nim LSP は `nimlangserver` のみに。
> - A-8 ✅ 対応済み（2026-09-09）。詳細は「A-8」節末尾。
> - A-9 ✅ `options.lua` に `loaded_perl/ruby/node_provider = 0` を追加（python3 は defx のため残置）。
>
> **副次的に判明**: `registers.nvim`（`tversteeg/registers.nvim`）の GitHub リポジトリが
> **404（削除済み）**。ローカルのクローンは残っているので動作はするが更新不可。
> A の対象外だが、いずれ削除かフォークへの切り替えが必要。

### A-1. `markdown-preview.nvim` のビルドが走っておらず壊れている

```lua
-- lua/plugins/markdown.lua （現状）
"iamcco/markdown-preview.nvim",
run = "cd app && npm install",   -- ← packer のキー。lazy.nvim では無効
setup = function() ... end,       -- ← packer のキー。lazy.nvim では無効
```

`run` / `setup` は **packer.nvim のキー**。lazy.nvim は `build` / `init` を使う。
実際 `app/node_modules` が存在せず、`:MarkdownPreview` は現状動かない。

```lua
-- 修正案
return {
  "iamcco/markdown-preview.nvim",
  build = function() vim.fn["mkdp#util#install"]() end,
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
```

導入後 `:Lazy build markdown-preview.nvim` を一度実行。
（代替案は D-6 の「バッファ内レンダリング」も参照）

### A-2. `incline.nvim` が有効化されていない（死んでいる）

`lua/plugins/utils.lua`:

```lua
{ "b0o/incline.nvim" },   -- opts も config も無い → setup() が呼ばれず何もしない
```

lazy.nvim は `opts` か `config` が無いと `setup()` を呼ばない。
→ **使うなら `opts = {}` を付ける。使わないなら削除。**

```lua
{
  "b0o/incline.nvim",
  event = "VeryLazy",
  opts = {
    highlight = { groups = { InclineNormal = { group = "lualine_a_normal" } } },
    window = { margin = { vertical = 0 } },
    hide = { cursorline = true },
  },
},
```

### A-3. `indent-blankline.nvim` も有効化されていない（死んでいる）

`lua/plugins/utils.lua`:

```lua
{ "lukas-reineke/indent-blankline.nvim" },  -- require("ibl").setup() が呼ばれていない
```

インデントガイドとして実際に動いているのは **`hlchunk.nvim` だけ**。
→ **`indent-blankline.nvim` はまるごと削除**でよい（重複していない、片方は無効なだけ）。
hlchunk 側で `chunk` / `indent` 両方出せるので機能的にも足りている。

### A-4. `lspkind.nvim` が未使用

`lua/plugins/cmp.lua` の `formatting = { format = lspkind.cmp_format(...) }` が
コメントアウトされているため、`lspkind` は入っているだけで使われていない。
→ 補完メニューにアイコンを出したいならコメントを外す。出さないなら依存ごと削除。

### A-5. Copilot の cmp ソースが実体なし

`lua/plugins/cmp.lua`:

```lua
{ name = "copilot", group_index = 2 },   -- ← このソースを提供する copilot-cmp は
                                          --    コメントアウトされていて存在しない
```

現状 Copilot 補完は `copilot.vim` の�​ースト​テキストのみ。cmp メニューには出ない。
どちらかに統一する:

- **A案（Lua に寄せる）**: `zbirenbaum/copilot.lua` + `fang2hou/blink-copilot`（blink 移行時）
  もしくは `zbirenbaum/copilot-cmp`（cmp 継続時）。`copilot.vim` は削除。
- **B案（現状維持で整合）**: `{ name = "copilot" }` の行を削除し、`copilot.vim` の
  ゴーストテキストだけ使う。

### A-6. `<leader>cd` が二重定義（CopilotChat）

`lua/plugins/copilot.lua` の `prompts` 内で `Docs` と `FixDiagnostic` が
どちらも `mapping = "<leader>cd"`。後勝ちで `Docs` が潰れる。
→ 片方を `<leader>cD` などに変更。

### A-7. Nim の LSP が二重に有効化

`checkhealth`（vim.lsp）で `nim_langserver` と `nimls` の両方が enabled。
Mason に両方入っているため `mason-lspconfig` が両方 attach している。
→ どちらか一方だけ Mason に残す（`nim_langserver` = nimlangserver 推奨、`nimls` は旧実装）。

### A-8. LSP ログが 100MB まで肥大化（ログレベルの問題ではない）

`checkhealth`: `Log size: 88370 KB` → 実ファイル `~/.local/state/nvim/lsp.log` は現在 **100M**。

**内訳を調べた結果**（209,715 `[ERROR]` 行のうち **191,190 行が `"stderr"`**）:

| 発生源 | 行数 | 原因 |
|---|---|---|
| clangd | ~53,000 | `~/Documents/Reports/Jouhousyori/` などの単体 `.c` を開くと `compile_commands.json` が無く「Failed to find compilation database」+ ASTWorker のフル clang コマンドを毎回吐く |
| Copilot (`npx`) | ~4,000 | `cmd = { "npx", "@github/copilot-language-server@^1.408.0", ... }` が起動のたびにパッケージを再解決・再インストールし `npm warn` を stderr に出す |
| Copilot handler | ~8,000 | `streamChoices` / `Request id invalid` エラー（既知のノイズ） |

**重要**: ログレベルは既定の `WARN`（現状もそう）。にもかかわらず 100MB なのは、
**言語サーバの stderr 出力はログレベルに関係なく `[ERROR]` として記録される**ため。
`vim.lsp.set_log_level("OFF")` にすればこの stderr 記録も止まるが、**ログの安全網ごと失う**
（→ ユーザーの質問への回答は本文 A-8 補足を参照。基本は `OFF` にしない方がよい）。

**推奨対応（レベル変更より根本原因）**:

1. ノイズ源を潰す:
   - clangd: 対象ディレクトリに `compile_flags.txt`（例: `-std=c17` の1行）か `.clangd` を置く。
     または「プロジェクト外のファイルには clangd を attach しない」ルート設定にする。
   - Copilot: `npx` をやめ、Mason の `copilot-language-server` かバイナリ直指定に。
     もしくは `copilot.lua` に移行（バイナリを自前管理してくれる）。
2. サイズガードを入れて再肥大化を防ぐ（`init.lua` か options 相当の場所）:

   ```lua
   local p = vim.lsp.get_log_path()
   local st = vim.uv.fs_stat(p)
   if st and st.size > 5 * 1024 * 1024 then
     vim.fn.writefile({}, p)
   end
   ```
3. レベルは `WARN`（既定）か `ERROR` のまま。デバッグ時だけ一時的に
   `:lua vim.lsp.set_log_level("debug")` → 再現 → `:LspLog` → 戻す。
4. 既存ファイルを一度リセット: `rm ~/.local/state/nvim/lsp.log`（100MB 回収）

---

**実施内容（2026-09-09）** ✅

1. `rm ~/.local/state/nvim/lsp.log`（100MB 回収）。
2. **`init.lua` に起動時サイズガード**を追加（5MB 超で truncate）。
   `vim.lsp.get_log_path()` は 0.12 で非推奨のため `vim.lsp.log.get_filename()` を使用:
   ```lua
   do
     local ok, logpath = pcall(vim.lsp.log.get_filename)
     if ok and logpath then
       local stat = vim.uv.fs_stat(logpath)
       if stat and stat.size > 5 * 1024 * 1024 then
         vim.fn.writefile({}, logpath)
       end
     end
   end
   ```
3. **clangd ノイズ源対策**:
   - `~/Documents/大学/Reports/Jouhousyori/compile_flags.txt` に `-std=gnu17`
     （情報処理演習の C ファイル群 20 本。旧パス `~/Documents/Reports/…` から移動していた）。
   - `~/.config/clangd/config.yaml` にグローバル既定（`CompileFlags: Add: [-std=gnu17]`）。
     `~/Develop/Study/*` 等の単発 `.c` にも適用される。
   - 検証: `q02.c` を開くと clangd が `-std=gnu17` 付きで attach、
     `compilation database` / ASTWorker ノイズが ~53,000 行 → 1 行に激減。

> ログレベルは既定の `WARN` のまま（`OFF` にはしない）。`vim.log` のサイズガードで
> 再肥大化は防げる。他ディレクトリで新たにノイズが出たら、そこに `compile_flags.txt` を置くか
> グローバル `config.yaml` に include パスを足す。

### A-9. 不要な言語プロバイダの警告

**プロバイダとは**: Neovim は Python/Ruby/Perl/Node のインタプリタを本体に埋め込まず、
別プロセス（host）として RPC 経由で起動する。この橋渡しが「プロバイダ」。
用途は (1) `:python3` 等をインラインで呼ぶ旧 Vim プラグイン、(2) `rplugin/{python3,node,ruby}/`
を持つ「リモートプラグイン」。**Lua 製プラグインはどれも使わない**（内蔵 LuaJIT で動く）。
※ clipboard プロバイダだけは別物（`"+`/`"*` レジスタの実体 = pbcopy）。触らない。

`rplugin/` とリモートホスト登録を実際に調べた結果:

| プロバイダ | この設定で使っているもの | 判断 |
|---|---|---|
| **python3** | **`defx.nvim`**（`rplugin/python3/defx`）が必要 | **defx がある間は無効化しない**。oil.nvim 等へ移行後（D-1）に無効化可 |
| **node** | リモートホストを持つプラグインなし。`markdown-preview` は自前 node サーバ、Copilot は `npx` 直呼びで、どちらもプロバイダとは無関係 | **今すぐ無効化して問題なし** |
| **ruby** | `rplugin/ruby` はどこにも無い | **今すぐ無効化可** |
| **perl** | 使用なし | **今すぐ無効化可** |

```lua
-- lua/settings/core/options.lua など（lazy より前）
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0  -- ← defx を外してから
```

無効化すると `has('python3')` 等が 0 になり、そのプロバイダを feature 判定している
プラグインは該当機能を黙ってスキップする。起動時間の短縮は healthcheck / autoload の
プローブ分でごく僅か。主目的は「不要な警告を消す」＋「意図しない host 起動を防ぐ」。
なお vimtex 等が `system('python3 ...')` で **実行ファイル** を呼ぶのは別処理で、
`loaded_python3_provider` の影響を受けない。

---

## B. パフォーマンス: 遅延読み込み（優先度: 高）

> **実施状況（2026-09-06）**: B-1〜B-4 すべて適用済み。
> **起動時間（headless, warm）: 約 275ms → 約 95〜105ms（約 2.7 倍高速化）。**
>
> - B-1 ✅
>   - `nvim-cmp` … `event = { "InsertEnter", "CmdlineEnter" }`。cmp-path / cmp-buffer /
>     cmp-cmdline / cmp-nvim-lsp / vim-vsnip / lspkind を **`dependencies` に集約**
>     （従来はトップレベル spec で起動時ロードされていた）。
>   - `CopilotChat.nvim` … `cmd` + `keys`（`<leader>c*` を lazy キー登録）。
>     `github/copilot.vim` は独立 spec に分離し `event = "InsertEnter"`
>     （チャットの遅延に引きずられてゴーストテキストが死ぬのを防ぐ）。
>   - `mason.nvim` … `cmd = { "Mason", ... }`。
>   - `mason-lspconfig.nvim` … `event = { "BufReadPre", "BufNewFile" }` +
>     `dependencies = { mason.nvim, nvim-lspconfig, cmp-nvim-lsp }`。
>     → 実ファイルを開くと LSP が有効化される流れは維持（`lua_ls` / `null-ls` の attach を確認）。
>   - `nvim-lspconfig` / `none-ls` … `event = { "BufReadPre", "BufNewFile" }`。
>   - `telescope` … `cmd` + `keys`（`config` は不要になり削除）。
>   - `toggleterm` … `cmd = { "ToggleTerm", "TermExec", "T" }` + `keys`。
>   - `trouble` … `cmd = "Trouble"`。
>   - `todo-comments` … `event = { "BufReadPost", "BufNewFile" }`。
>   - `vim-startuptime` … `cmd = "StartupTime"`。
>   - `vim-fugitive` … `cmd = { "Git", "G", ... }`。
>   - `image.nvim` … `ft = { "markdown", "vimwiki" }`（B の一覧外だが同種の効果）。
> - B-2 ✅ `vim-airline`(+themes) / `vim-highlightedyank` / `vim-commentary` /
>   `registers.nvim` / `vim-sandwich` / `vimdoc-ja` → `event = "VeryLazy"`。
>   `vim-gitgutter` は署名描画が要るため `event = { "BufReadPre", "BufNewFile" }`。
> - B-3 ✅ `settings/lazy.lua` に `change_detection = { notify = false }` と
>   `performance.rtp.disabled_plugins = { gzip, tarPlugin, tohtml, tutor, zipPlugin }`。
> - B-4 ✅ `vim.loop.fs_stat` → `(vim.uv or vim.loop).fs_stat`。
>
> **補足（B の範囲外の既知バグ）**: `cmp.lua` は `opts`（lazydev ソースを追加する関数）と
> `config`（`cmp.setup({...})` をハードコード）が両立しており、`config` が opts の結果を
> 使っていないため **lazydev 補完ソースが無効**。C/D の整理時に `config` 内で
> `cmp.setup(opts)` を使う形へ寄せると直る。

`--startuptime` 上位（対応前・起動時に無条件ロードされていたもの）:

| モジュール | 自コスト | 本来のトリガ |
|---|---|---|
| `CopilotChat` 一式 | ~30ms | `cmd = { "CopilotChat*" }` / キー |
| `mason` + `mason-lspconfig` | ~30ms | `cmd = "Mason"` / `FileType` |
| `cmp` + `cmp.core` | ~24ms | `event = "InsertEnter"` |
| `null-ls`(none-ls) | ~7ms | `event = { "BufReadPre", "BufNewFile" }` |
| `vim.lsp` / lspconfig | ~8ms | `event = { "BufReadPre", "BufNewFile" }` |

### B-1. 主要プラグインに lazy トリガを付ける

```lua
-- nvim-cmp
{ "hrsh7th/nvim-cmp", event = "InsertEnter", ... }

-- CopilotChat
{
  "CopilotC-Nvim/CopilotChat.nvim",
  cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
  keys = { { "<leader>cc", "<cmd>CopilotChatOpen<cr>", desc = "Copilot Chat" } },
  ...
}

-- none-ls / lspconfig
{ "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" }, ... }
{ "nvimtools/none-ls.nvim", event = { "BufReadPre", "BufNewFile" }, ... }

-- mason は cmd で十分（LSP 起動自体は lspconfig 側が担う）
{ "williamboman/mason.nvim", cmd = "Mason", ... }

-- telescope
{
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
  },
}

-- toggleterm
{ "akinsho/toggleterm.nvim", cmd = { "ToggleTerm", "TermExec" }, keys = { "<leader>t" }, ... }

-- trouble / todo-comments / template / vim-startuptime / fugitive
{ "folke/trouble.nvim", cmd = "Trouble", keys = { ... } }
{ "folke/todo-comments.nvim", event = { "BufReadPost", "BufNewFile" } }
{ "dstein64/vim-startuptime", cmd = "StartupTime" }
{ "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gblame" } }
```

### B-2. `VeryLazy` イベントを活用

見た目系（incline、gitsigns、highlightedyank、todo-comments のUI）は
`event = "VeryLazy"` で「起動後アイドル時」にまとめてロード。

### B-3. lazy.nvim 本体で不要な標準プラグインを無効化

```lua
-- lua/settings/lazy.lua
require("lazy").setup("plugins", {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
        "netrwPlugin",  -- ← 別のファイラを使う場合のみ
      },
    },
  },
  change_detection = { notify = false },
})
```

### B-4. `vim.loop` → `vim.uv`

`lua/settings/lazy.lua` の `vim.loop.fs_stat` は非推奨エイリアス。`vim.uv.fs_stat` に。

---

## C. 非推奨 API・古い書き方（優先度: 中）

> **実施状況（2026-09-06）**: C-1〜C-4 完了。C-5（好み）は未対応。
>
> - **C-1** ✅ 済（`vim.diagnostic.config()` / `vim.diagnostic.jump()`）。
> - **C-2** ✅ `haskell.lua`: `version = "^4"` → **`version = "^10"`**（haskell-tools v10、Neovim 0.12+ 前提）。
>   `hls.capabilities` の明示行を削除（v10 は blink.cmp を自動検出）。
>   `:checkhealth haskell-tools` の `vim.validate{<table>} is deprecated` 大量警告が解消、
>   `No errors found in config` / HLS 2.14.0.0 検出を確認。`hls.on_attach` の API は v10 でも同じ。
> - **C-3** ✅ `mason.lua`: `williamboman/*` → **`mason-org/mason.nvim` + `mason-org/mason-lspconfig.nvim`**（v2）。
>   `version = "^1.0.0"` ピン削除。v2 で廃止された `setup_handlers` → **`automatic_enable = { exclude = { "hls" } }`**。
>   `vim.lsp.config("*", { capabilities = blink })` は維持。既存 22 パッケージはそのまま引き継ぎ、
>   `lua_ls` / `pyright` の attach を確認。
>   ※ mason は `cmd` 遅延なので `:checkhealth mason` は `:Mason` を一度開いてから実行（B 由来の仕様）。
> - **C-4** ✅ `lspconfig.lua`: LSP 固有キー（`gd`/`gD`/`gr`/`gi`/`gN`/`<C-h>`/`<C-k>`）を
>   **`LspAttach` autocmd でバッファローカル化**。診断（`<C-e>`/`ge`/`[p`/`[n`）とバッファ移動（`gn`/`gp`）は
>   LSP 非依存なのでグローバル据え置き。非 LSP バッファに `gd` 等が生えないことを確認。
> - **C-5** ⬜ 未対応（`<C-h>`→`K` / `<C-k>`→`<C-s>` は好み。現状維持でも問題なし）。
>
> 補足: `gr`（参照）はバッファローカルになったが、Neovim 0.11 標準の `gr` プレフィックス
> （`grr`/`gri`/`grn`/`gra`）と前方一致するため、LSP バッファでは `gr` 実行に `timeoutlen` 分の
> 待ちが入る。気になる場合は `gr`→`grr` へ寄せるか `timeoutlen` を下げる。

### C-1. （対応済み）`vim.lsp.with()` / `vim.diagnostic.goto_prev/next`

`lspconfig.lua` は `vim.diagnostic.config()` と `vim.diagnostic.jump()` に修正済み。

### C-2. `haskell-tools.nvim` のバージョンピンを外す

`lua/plugins/haskell.lua` のコメントは「Neovim 0.11 なので v4 に固定、0.12 に上げたら
bump」とある。**もう 0.12 なので `version = "^4"` を削除**（最新へ）。
`checkhealth` の `vim.validate{<table>} is deprecated` 警告も新しい haskell-tools では解消済み。

### C-3. `mason` / `mason-lspconfig` の v2 移行を検討

現状 `version = "^1.0.0"` に固定（`setup_handlers` を使っているため）。
mason v1 は更新終了。v2 では:

```lua
-- mason-lspconfig v2: setup_handlers 廃止 → automatic_enable
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "bashls", ... },
  automatic_enable = true,   -- Mason が入れた LSP を vim.lsp.enable で自動有効化
})
```

`vim.lsp.config("*", { capabilities = ... })` は現状のままでよい。

### C-4. LSP キーマップを `LspAttach` でバッファローカルに

現状 `lspconfig.lua` の `gd` `gr` 等は**全バッファに無条件で** `vim.keymap.set`。
LSP が付いていないバッファでも定義されてしまう。

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(m, l, r) vim.keymap.set(m, l, r, { buffer = ev.buf, silent = true }) end
    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gr", vim.lsp.buf.references)
    map("n", "gi", vim.lsp.buf.implementation)
    -- ...
  end,
})
```

なお Neovim 0.11 から `grn`(rename) / `gra`(code action) / `grr`(references) /
`gri`(implementation) / `K`(hover) / `<C-s>`(signature, 挿入) は**標準キーマップ**。
既存の `gN` `gr` `gi` などは標準に寄せると設定が減らせる。

### C-5. `<C-h>` = hover / `<C-k>` = signature の見直し（好み）

`<C-h>` `<C-k>` はウィンドウ移動に割り当てる人が多い。標準の `K` / `<C-s>` に寄せると
衝突が減る。現状維持でも動作上の問題はない。

---

## D. プラグイン代替案（優先度: 中〜低）

> **実施状況（2026-09-06）**: ユーザー選択（ファイラ = oil.nvim / blink.cmp 移行 = する）に基づき、
> 表の主要項目をすべて適用済み。起動時間は B 時点から横ばい（headless warm 約 105〜125ms）。
>
> | 置換 | 状態 | メモ |
> |---|---|---|
> | defx.nvim(+defx-icons/defx-git/vim-devicons) → **oil.nvim** | ✅ | `lua/plugins/defx.lua` 削除 → `filer.lua` 新規（oil + trouble）。`-` / `<leader>e` で開く。`h`/`l`/`q`/`~` を defx 風に割当。`options.lua` で `loaded_python3_provider = 0` も追加 |
> | vim-airline(+themes) → **lualine.nvim** | ✅ | `utils.lua`。`theme = "tokyonight"`, `globalstatus = true`, `event = "VeryLazy"` |
> | vim-gitgutter → **gitsigns.nvim** | ✅ | `utils.lua`。`on_attach` で `]c`/`[c`/`<leader>hs`/`hr`/`hp`/`hb` |
> | vim-commentary → **削除** | ✅ | Neovim 0.12 標準の `gc`/`gcc`/`gc{motion}` を使用 |
> | none-ls.nvim → **conform.nvim** | ✅ | `nullls.lua` 削除 → `conform.lua` 新規。stylua/nimpretty/black/php_cs_fixer。`:Format` と `<C-f>` を conform 側へ移設し `lspconfig.lua` から削除。擬似 LSP クライアント `null-ls` が消えた |
> | nvim-cmp(+cmp-*/vim-vsnip/lspkind) → **blink.cmp** | ✅ | `cmp.lua` を全面書き換え（v1.10.2、Rust バイナリ取得済み）。`friendly-snippets` + `blink-copilot` を依存に。lazydev/copilot を `sources.providers` で接続。capabilities は `mason.lua` / `haskell.lua` を `require("blink.cmp").get_lsp_capabilities()` に変更。`noice.lua` の `cmp.entry.get_documentation` override を削除 |
> | copilot.vim → **copilot.lua** | ✅ | `copilot.lua`。`suggestion`/`panel` は無効化し補完は blink-copilot 経由。CopilotChat の依存も差し替え |
> | （追加）**render-markdown.nvim** | ✅ | `markdown.lua`。markdown-preview（ブラウザ）は残置、バッファ内整形を併設 |
> | onedark.nvim → **削除**、tokyonight を一本化 | ✅ | `colorscheme.lua`。`lazy=false, priority=1000` + `vim.cmd.colorscheme("tokyonight")` |
> | vim-sandwich | ⬜ 据え置き | 提案表でも「現状でも可」。Lua 化したくなったら mini.surround 等 |
> | template.nvim / registers.nvim | ⬜ 据え置き | 使用頻度次第。registers は N-1（リポジトリ 404）の判断待ち |
>
> **検証**: 起動時エラーなし／`.lua` で `lua_ls` attach（capabilities は blink 由来）／
> InsertEnter で blink.cmp ロード／`:Oil` 起動／gitsigns attach／lualine で `laststatus=3`／
> `.md` で render-markdown + image.nvim ロード／`colors_name = tokyonight-storm`／
> `:checkhealth vim.provider` は 4 プロバイダすべて Disabled。
>
> **移行に伴う注意点**:
> - 補完キーマップが blink 仕様に変化: `C-space` 表示 / `C-y` 確定 / `CR` 確定 /
>   `Tab`・`S-Tab` 選択＋スニペットジャンプ / `C-n`,`C-p` 選択 / `C-b`,`C-f` doc スクロール /
>   `C-k` シグネチャ / `C-e` 非表示 / `C-l` 手動表示。
> - vim-vsnip の自作スニペットがあれば friendly-snippets 形式へ要移植（標準スニペットのみなら不要）。
> - `haskell.lua` は `lazy = false` のため `require("blink.cmp")` を起動時に呼ぶ（+数 ms）。
>   気になるなら capabilities 行を消して `mason.lua` の `vim.lsp.config("*")` 側に任せられる。
> - `init.lua` の `vim.g.python3_host_prog` は provider 無効化で未使用（残しても無害）。

### D-copilot. Copilot を「既定オフ・`:Copilot enable` の時だけ起動」に … ✅ 実施済み（2026-09-06）

たまにしか使わないため、起動時・InsertEnter では Copilot を一切動かさない構成にした。

- **`copilot.lua`（spec）**: `event = "InsertEnter"` → **`cmd = "Copilot"`** に変更。
  `:Copilot ...`（`plugin/copilot.lua` が実コマンドを定義）を叩いたとき、または CopilotChat 起動時にだけロード。
  `config` で `require("copilot").setup(opts)` 直後に `require("copilot.command").disable()` を呼び、
  ロードされても既定はオフ。`opts.filetypes = { ["*"] = true }`。
- **`cmp.lua`（blink.cmp）**: `sources.default` を関数化し、
  `package.loaded["copilot.client"]` かつ `client.get() ~= nil`（＝ Copilot 起動中）のときだけ
  補完ソースに `"copilot"` を足す。未ロード時は `package.loaded` を見るだけなので lazy の
  require フックを踏まない。
- **挙動**:
  - 起動時／InsertEnter … copilot.lua はロードされない。blink は `lsp,path,snippets,buffer,lazydev`。
  - `:Copilot enable` … ロード＋有効化。以降 blink に `copilot` ソースが加わる。
  - `:Copilot disable` … 無効化。blink から `copilot` が外れる。
  - `:Copilot status` … ロードのみ（無効のまま）。
  - CopilotChat 起動 … copilot.lua は依存でロードされるが**無効のまま**（チャットはトークンで動作）。
- **検証済み**: 上記すべてを headless で確認。起動エラーなし。

### 旧・提案表（参考）

| 現状 | 種別 | 代替案 | 理由 |
|---|---|---|---|
| **defx.nvim** + defx-icons + defx-git + vim-devicons | ファイラ | **oil.nvim**（バッファ型）/ neo-tree.nvim / mini.files | defx は Python リモートプラグイン依存で重く、ほぼメンテ停止。移行で 4 プラグイン+python provider を削減 |
| **vim-airline** + vim-airline-themes | ステータスライン | **lualine.nvim** / mini.statusline | VimL で遅め。Lua 製は軽くテーマ連携も楽。incline と役割分担しやすい |
| **vim-gitgutter** | Git 差分表示 | **gitsigns.nvim** | 非同期で高速。hunk ステージ/プレビュー/blame、ステータスライン連携。VimL → Lua |
| **vim-commentary** | コメント | **削除**（Neovim 0.10+ の標準 `gc`/`gcc` で十分） | 標準機能と重複 |
| **none-ls.nvim** (stylua/black/nimpretty/phpcsfixer) | フォーマット | **conform.nvim** + 必要なら nvim-lint | 疑似 LSP を立てない分軽い。`black` → `ruff format` で高速化も |
| **nvim-cmp** + cmp-* + vim-vsnip | 補完 | **blink.cmp**（+ LuaSnip か標準 `vim.snippet`） | nvim-cmp は概ねメンテナンスモード。blink は Rust ファジー・一体型で高速。※移行は任意 |
| **copilot.vim** | Copilot | **copilot.lua** | Lua、cmp/blink 連携が容易。A-5 と合わせて整理 |
| **markdown-preview.nvim** | Markdown | ブラウザ不要なら **render-markdown.nvim** / markview.nvim | バッファ内で見出し・表・コードを整形。image.nvim とも相性良 |
| **vim-sandwich** | 囲み操作 | mini.surround / nvim-surround（好みで、現状でも可） | Lua 化したいなら。機能的には sandwich で十分 |
| **onedark.nvim**（実質未使用） | 配色 | 使わないなら削除、使うなら `lazy=false, priority=1000` で一本化 | tokyonight が `.load()` で勝っている |
| **template.nvim** | テンプレート | 標準の `:h skeleton`(autocmd) / snippets でも可 | 使用頻度次第 |
| **registers.nvim** | レジスタ表示 | 標準 `"` / `<C-r>` + which-key でも可 | 使用頻度次第 |

### D-1. ファイラ移行例（oil.nvim）

```lua
{
  "stevearc/oil.nvim",
  lazy = false,
  opts = { view_options = { show_hidden = true } },
  keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent dir" } },
}
```

移行で削除できるもの: `defx.nvim` / `defx-icons` / `defx-git` / `ryanoasis/vim-devicons`
（+ defx 用の複雑な VimL キーマップ約60行、`python3_host_prog` 依存）。

### D-2. gitsigns 移行例

```lua
{
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(buf)
      local gs = require("gitsigns")
      local map = function(l, r) vim.keymap.set("n", l, r, { buffer = buf }) end
      map("]c", function() gs.nav_hunk("next") end)
      map("[c", function() gs.nav_hunk("prev") end)
      map("<leader>hs", gs.stage_hunk)
      map("<leader>hp", gs.preview_hunk)
      map("<leader>hb", function() gs.blame_line({ full = true }) end)
    end,
  },
}
```

### D-3. conform.nvim 移行例

```lua
{
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },   -- or { "black" }
      nim = { "nimpretty" },
      php = { "php_cs_fixer" },
    },
    -- format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
  },
  keys = {
    { "<C-f>", function() require("conform").format({ lsp_format = "fallback" }) end, mode = { "n", "v" } },
  },
}
```

`:Format` ユーザーコマンドと `<C-f>` は conform 側に移せる。

### D-6. Markdown バッファ内レンダリング（image.nvim と併用推奨）

```lua
{
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  opts = {},
}
```

---

## E. `options.lua` / `keymaps.lua` の拡充提案

> **実施状況（2026-09-06）**: `options.lua` 拡充 ✅ 完了。
> ユーザー選択: **インデント = スペース 4**（`expandtab`/`shiftwidth=4`/`tabstop=4`/`softtabstop=4`/`smartindent`/`shiftround`）、
> **小物 = `cursorline` + `mouse = "a"`**（relativenumber は入れず）。
> ほかに `ignorecase`+`smartcase`、`termguicolors`、`signcolumn="yes"`、`scrolloff`/`sidescrolloff=8`、
> `splitright`/`splitbelow`、`pumheight=12`、`showmode=false`、`list`+`listchars`、
> `undofile`、`swapfile=false`、`updatetime=250`、`timeoutlen=400` を追加。
> `laststatus`（lualine）/ `completeopt`（blink）/ `ambiwidth`（据え置き）は触らず。
>
> **`keymaps.lua` 拡充 ✅ 完了（2026-09-09）**。`map()` ヘルパに整理し以下を追加:
> - 編集補助: Visual `<`/`>` で選択維持、`J`（連結でカーソル固定）、Visual `J`/`K` で選択行移動
> - 中央寄せ: `n`/`N`/`<C-d>`/`<C-u>`
> - レジスタ非汚染: `<leader>p`（Visual、ヤンク保持ペースト）、`<leader>d`（ブラックホール削除）、`x`（1 文字削除）
> - 保存・バッファ: `<leader>w`、`<leader>bd`、**`<S-h>`/`<S-l>` でバッファ移動**
> - これに伴い `lspconfig.lua` の `gn`/`gp`（= `:bnext`/`:bprevious`）を削除 →
>   `gn` は標準の「次の検索マッチを Visual 選択」に復帰。
> - which-key spec に `<leader>b` = Buffer グループを追加。`:checkhealth which-key` は overlap/duplicate なし。
> - **ウィンドウ移動キー（`<C-h/j/k/l>`）のみ見送り**（`<C-h>`=hover / `<C-k>`=signature と衝突。C-5 とセット）。

（以下は当初の提案内容）現状 `options.lua` は 7 項目のみ。最低限このあたりを追加すると編集体験が大きく変わる:

```lua
local opt = vim.opt

-- インデント
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.shiftround = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- UI
opt.termguicolors = true      -- WezTerm では自動 true だが明示
opt.signcolumn = "yes"        -- 診断でガタつかない
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.pumheight = 12
opt.showmode = false          -- noice/lualine があるので

-- 編集
opt.undofile = true           -- 永続 undo
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.mouse = "a"
opt.completeopt = "menu,menuone,noselect"

-- 表示
opt.list = true
opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }
```

`keymaps.lua` に足すと便利なもの（好みで）:

```lua
-- ウィンドウ移動
vim.keymap.set("n", "<C-w>h", "<C-w>h")  -- ※ <C-h> は hover に使用中
-- バッファ移動（現状 gn/gp が bnext/bprev に割当。標準の gn は「次の検索マッチを選択」なので
-- <S-h>/<S-l> や <Tab>/<S-Tab> への変更を検討）
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>")
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>")

-- 保存・終了
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>")

-- Visual インデント維持
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- 検索結果を中央に
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
```

> 注: 現状 `gn` / `gp` を `:bnext` / `:bprevious` に上書きしている。`gn` は
> 標準で「次の検索マッチを Visual 選択」という便利機能なので、バッファ移動は
> 別キーにするのがおすすめ。

### E-wk. which-key.nvim ＋ desc 埋め … ✅ 実施済み（2026-09-06）

「キーバインドを忘れる」対策として導入。

- **`lua/plugins/whichkey.lua` 新規**: `preset = "modern"`（好みで `classic`/`helix`）。
  `<leader>c`=Copilot / `<leader>f`=Find / `<leader>h`=Git hunk・Haskell / `<leader>t`=Terminal のグループ名。
  `<leader>?` で「このバッファのキーマップ一覧」をポップアップ。
- **`desc` 埋め**:
  - `lua/settings/core/keymaps.lua` … `mp` / `<leader><Space>` / `<leader>q` / 端末 `<ESC>`
  - `lua/plugins/lspconfig.lua` … `gd`/`gD`/`gr`/`gi`/`gN`/`ge`/`<C-h>`/`<C-e>`/`<C-k>`/`[p`/`[n`/`gn`/`gp` に日本語 desc（`map()` ヘルパに整理）
  - `lua/plugins/haskell.lua` … `<leader>hh`/`he`/`hr`/`hR`/`hq`
  - `lua/plugins/telescope.lua` … 既存を日本語化 ＋ **`<leader>fk` = `:Telescope keymaps`（キーマップ検索）を追加**
  - B/D で追加した `keys`（toggleterm / conform / oil / gitsigns / CopilotChat）は既に desc 済み
- **検証**: `:checkhealth which-key` → overlapping / duplicate なし（optional の mini.icons のみ未導入、web-devicons で代替）。起動エラーなし。

補足: `lspconfig.lua` のキーマップはまだ**グローバル**なので which-key は全バッファで表示する。
C-4（`LspAttach` でバッファローカル化）を実施するとより正確になる。

---

## F. その他の小ネタ

- **`vimtex.lua`**: `lazy = false` と `ft = { "tex" }` が併記されているが `lazy=false` が
  優先され `ft` は無視される。コメント通り遅延しない方針なら `ft` 行を削除して意図を明確に。
- **`colorscheme.lua`**: アクティブな配色（tokyonight）に `lazy = false, priority = 1000` を付け、
  もう一方は削除 or `lazy = true`。`config` で `vim.cmd.colorscheme("tokyonight")` が確実。
- **`archive/`**: `packer_compiled.lua` など 2023 年の遺物。読み込まれていないので実害なしだが
  リポジトリ整理としては削除候補。
- **`.DS_Store`**: `git status` に出ている。`~/dotfiles/.gitignore` に `.DS_Store` を追加。
- **`cmp.lua` の `<Tab>`**: `select_next_item()` のみでフォールバック無し。補完が出ていない時に
  Tab が効かない。`cmp.mapping(function(fallback) ... end, {"i","s"})` 形式でスニペットジャンプや
  通常 Tab にフォールバックさせると自然。
- **CopilotChat**: `vim.ui.select` がデフォルト実装。`opts` に
  `selection = require("CopilotChat.select").visual` などの整備、または telescope 連携で UX 改善。
  `gh` CLI を入れると認証まわりが安定（`brew install gh`）。
- **haskell-tools**: `hoogle` 未インストール。`brew install hoogle` でローカル Hoogle 検索が有効に。
- **Node `neovim` パッケージが古い**（5.2.0 → 5.4.0）。使っていないなら `loaded_node_provider = 0`、
  使うなら `pnpm add -g neovim`。
- **`vim-startuptime`** があるので、B の遅延化前後で `:StartupTime` を撮って効果を確認できる。

---

## 推奨着手順

### 完了済み

1. ~~treesitter master→main / telescope v0.2.2 / deprecation(C-1)~~ … ✅ 0.12 アップグレード不具合の解消
2. ~~**A（不具合修正）**~~ … ✅ A-8 以外完了
3. ~~**B（遅延読み込み）**~~ … ✅ B-1〜B-4 完了。起動 275ms→~100ms
4. ~~**D（プラグイン置換）**~~ … ✅ 主要項目すべて完了（oil / lualine / gitsigns / conform / blink.cmp / copilot.lua / render-markdown / tokyonight 一本化、vim-commentary 削除）
5. ~~**which-key + desc 埋め**（E-wk）~~ … ✅ 完了。`<leader>?` でバッファのキー一覧、`<leader>fk` でキーマップ検索
6. ~~**Copilot 既定オフ**（D-copilot）~~ … ✅ `:Copilot enable` の時だけ起動
7. ~~**C（非推奨 API）**~~ … ✅ C-1〜C-4 完了（haskell-tools v10 / mason v2 / LspAttach）。C-5 は好みのため見送り

8. ~~**N-1 / F-1 / F-2 / F-4**~~ … ✅ registers.nvim 削除 / vimtex を `ft` 遅延化 / `.DS_Store` を gitignore / `python3_host_prog` 削除
9. ~~**A-8**~~ … ✅ `rm lsp.log` ＋ 起動時サイズガード（`init.lua`）＋ clangd の `compile_flags.txt` / グローバル `config.yaml`

### これから（推奨順）

10. **動作確認（実 GUI）** … blink.cmp の補完キー感、conform、oil、lualine、which-key、Haskell（HLS）、`:Mason`、C ファイルの clangd を WezTerm で確認。違和感があれば各 `opts` を微調整。
11. ~~**E（options / keymaps 拡充）**~~ … ✅ 完了（ウィンドウ移動キーのみ C-5 待ち）
12. **F の残り** … F-3 `archive/` 掃除（ユーザー対応予定）、F-5 CopilotChat の `gh` CLI、F-6 `hoogle`。
13. **C-5**（好み） … `<C-h>`→`K` / `<C-k>`→`<C-s>`、`gr`→`grr` へ寄せると 0.11 標準と衝突しない。
