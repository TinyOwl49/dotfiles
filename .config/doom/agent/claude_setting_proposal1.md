# Doom Emacs 設定 改善提案

対象: `~/.config/doom`（`init.el` / `config.el` / `packages.el`）
調査日: 2026-09-10
環境: macOS (Apple Silicon) / GNU Emacs 29.4 (emacs-plus@29, native-comp 有効) / Doom v2.2.0 (master `d1986c0`, 2026-07-15)
参照: `doom doctor` 出力、各設定ファイル、`emacs-org-latex-log.txt`、インストール済みフォント／LSP サーバの実地確認

> **起動時間（実測）**: デーモン起動での計測で **`emacs-init-time` = 0.77s**、
> Doom 自身のカウンタで **「174 packages across 43 modules in ~1.0s」**。GC は init 中 2 回のみ（ボトルネックではない）。
> GUI フレーム描画分を足して実効 1〜1.5s 程度。ネイティブコンパイル済みで、現状かなり健全。
> 計測手段は B-4 を参照。

---

## 調査サマリ

### 環境の要点

| 項目 | 現状 | 所見 |
|---|---|---|
| Emacs | 29.4（emacs-plus@29） | 30.1 が安定版。Doom は 30 を完全サポート。**アップグレード推奨**（B-1） |
| Doom | v2.2.0（2 か月前） | 十分新しい。`doom upgrade` は四半期に一度程度でよい |
| native-comp | 有効 | 良好。`sync` 直後の初回起動だけ再コンパイルで重い |
| tree-sitter | Doom 2.2 は**組み込み `treesit`** ベース（`libtree-sitter-*.dylib` を自動ビルド） | 旧 elisp-tree-sitter 問題は既に解消済み。追加対応不要（C は別項目） |
| LSP バックエンド | `:tools lsp +eglot`（eglot、lsp-mode ではない） | 軽量で良い選択。**ただし config が lsp-mode 前提の関数を呼んでいる**（A-1 / A-2） |
| straight パッケージ | `~/.config/emacs/.local/straight` が **344MB** | 通常範囲。肥大したら `doom gc` |
| 設定の git 管理 | `~/.config/doom` は **git 管理外**（nvim は dotfiles 配下） | dotfiles へ取り込み推奨（F） |

### インストール済み / 不足しているもの

- **フォント**: `FiraCode-VariableFont_wght.ttf`（可変フォント単体）、`FiraSans-Black.ttf`（**Black ウェイトのみ**）、
  `JetBrainsMono`（Light/Medium）、`Symbols Nerd Font Mono`、`BIZ UDGothic` / `BIZ UDMincho`。
  → `doom-font` / `doom-variable-pitch-font` の指定と噛み合っていない（A-3 / A-4）。CJK フォント未設定（A-5）。
- **LSP**: `rust-analyzer` ✅（rustup）、`pyright` ✅。
  **`typescript-language-server` ❌**（`:lang javascript +lsp` が実質死んでいる）、`ruff` ❌、`texlab` ❌、
  `bash-language-server` ❌、`marksman` ❌。
- **doom doctor 警告（8 件）**: Symbola フォント欠如 / `cmigemo` 欠如（`:input japanese` の migemo）/
  markdown コンパイラ欠如 / pipenv・pytest 欠如（`:lang python`）/ shellcheck 欠如 / stylelint・js-beautify 欠如。

### 優先度つき結論（詳細は各セクション）

1. **A（不具合）** ✅ 対応済み: eglot 構成なのに `lsp-deferred` / `lsp-format-buffer` を使用（2 か所、実際に動かない）。フォント指定が実体と不整合。CJK フォント未設定。`org-agenda-files` の起動時再帰スキャン。
2. **B（環境）** ✅ 対応済み: Emacs 30.2 へアップグレード（ユーザー実施→バイナリ切替後の `doom sync` 漏れで発生したエラーを解決）。agenda スキャンの限定。`doom gc`。起動時間ベースライン取得。
3. **C（古い書き方）** ✅ 対応済み: LaTeX プレビューの advice hack を撤去し、lualatex+luatexja ベースのプレビューに置き換え。調査の過程で「数式フラグメント中の日本語が無言で欠落する」実害を発見・修正。
4. **D（モジュール）**: `:lang latex` 追加（org の数式入力・プレビューが激変）、`:editor format` 追加、`:lang org` に `+dragndrop` / `+pretty`、`:completion` に `+icons`、プログラミング＋日本語の複合フォントへ乗り換え。
5. **外部ツール**: `cmigemo` / `ruff` / `typescript-language-server` / `texlab` / `pandoc` など。

---

## A. 今すぐ直したい不具合・死んでいる設定（優先度: 高）

> **実施状況（2026-09-10）: A-1〜A-8 すべて完了。** 変更は `config.el` のみ。反映は Emacs 再起動 or `SPC h r r`（`doom/reload`）。
>
> | # | 対応 | 備考 |
> |---|---|---|
> | **A-1** | `svelte-mode` の `:hook` を `lsp-deferred` → **`lsp!`**（Doom のバックエンド非依存 dispatch） | `.svelte` で実際に LSP を効かせるには `svelte-language-server` 導入＋eglot 登録が別途必要（D-6）。登録用のコメント雛形を `config.el` に併記 |
> | **A-2** | 壊れていた `SPC l f`（`lsp-format-buffer`）を削除し、**`SPC c f` → `eglot-format`** に上書き。`(autoload 'eglot-format "eglot" nil t)` も追加 | Doom 既定の `SPC c f`（`+format/region-or-buffer`）も `:editor format` 無しでは void だったため上書き。D-3 を入れたらこの `map!` は削除してよい |
> | **A-3** | `doom-variable-pitch-font` を **Fira Sans → Hiragino Sans**（Fira Sans は Black のみで極太化していた） | ユーザー選択: 追加インストールなし方針 |
> | **A-4** | `doom-font` の効かない **`:weight 'semi-light` を除去**（可変フォント単体で Emacs 29 は無視） | Fira Code のまま。細くしたいなら静的ウェイト版を別途 |
> | **A-5** | CJK フォントセットを明示。`after-setting-font-hook` で `kana`/`han`/`cjk-misc`/`bopomofo`/`japanese-jisx0208` → **BIZ UDGothic** | 等幅性が高く Org テーブルが崩れにくい。family 差し替えで Hiragino/Noto CJK にも変更可 |
> | **A-6** | = B-2。再帰スキャンを明示リスト管理へ（**B の作業で完了済み**） | — |
> | **A-7** | 死に設定 `(auto-save-visited-mode -1)` を**行ごと削除** | 既定で無効なので挙動変化なし |
> | **A-8** | `after-setting-font-hook` で `symbol` → Symbols Nerd Font Mono、`emoji` → Apple Color Emoji を `'append`（最低優先度）でフォールバック指定 | Symbola 未導入の代替。cask を入れるなら `brew install --cask font-symbola` |
>
> **検証**: デーモン起動でロードエラーなし／`svelte-mode-hook` に `lsp!`／`SPC c f` = `eglot-format`／
> `auto-save-visited-mode` = nil／`my/setup-fonts` が `after-setting-font-hook` に登録／
> `doom-font`=Fira Code・`doom-variable-pitch-font`=Hiragino Sans。
> フォントの実描画（グリフ・全角幅）は headless では確認不可のため、次回 GUI 起動時に目視確認をおすすめ
> （崩れる場合は `M-x doom/reload-font`、または BIZ UDMincho / Hiragino Sans に family 変更）。

### A-1. `svelte-mode` の `:hook` が eglot 構成で動かない

`config.el`:

```elisp
(use-package! svelte-mode
  :mode "\\.svelte\\'"
  :hook (svelte-mode . lsp-deferred))   ; ← lsp-deferred は lsp-mode の関数
```

`init.el` で `:tools lsp +eglot` を選んでいるため **lsp-mode はインストールされておらず**、
`lsp-deferred` は未定義。`.svelte` を開くと `void-function lsp-deferred` になるか、
`:hook` の解決に失敗して LSP が起動しない。

```elisp
;; 修正案: Doom が用意するバックエンド非依存の起動関数 lsp! を使う
(use-package! svelte-mode
  :mode "\\.svelte\\'"
  :hook (svelte-mode . lsp!))           ; eglot / lsp-mode どちらでも正しく dispatch
```

`lsp!` は `modules/tools/lsp/autoload.el` 提供。`+eglot` なら `eglot-ensure`、
そうでなければ `lsp-deferred` を呼ぶ。
（併せて A-2、および svelte 用 LSP サーバ `svelte-language-server` の導入も要検討 → D-6）

### A-2. `SPC l f` に割り当てた `lsp-format-buffer` も eglot では未定義

`config.el`:

```elisp
(map! :leader
      :desc "Format buffer with LSP"
      "l f" #'lsp-format-buffer)        ; ← これも lsp-mode の関数
```

同じ理由で eglot 構成では `lsp-format-buffer` は存在しない。押すとエラー。
さらに `SPC l` は Doom では **workspace/tab のプレフィックス**なので、ここに整形を
足すのは体系的にもズレている。整形は `SPC c f`（code → format）に寄せるのが Doom 流。

**推奨**: この `map!` を削除し、代わりに `:editor format` モジュールを有効化する（D-3）。
`SPC c f` = `+format/buffer` が eglot / apheleia 経由で動くようになる。
モジュールを増やしたくない場合の最小修正:

```elisp
(map! :leader :desc "Format buffer" "c f" #'eglot-format-buffer)
```

### A-3. `doom-variable-pitch-font "Fira Sans"` が Black ウェイトしか入っていない

インストール済みは `FiraSans-Black.ttf` のみ。可変ピッチ表示（Org 見出し、`*Help*`、
`markdown` の一部、`treemacs` など）がすべて極太で描画される。

**対応のいずれか**:
- Fira Sans の全ウェイトを入れる（`brew install --cask font-fira-sans` 等）。
- 可変ピッチフォントを実在するものに変更（例: `"Helvetica Neue"` / `"Hiragino Sans"` / D-5 の複合フォント）。
- こだわりが無ければ `doom-variable-pitch-font` の行自体を削除（Doom 既定にフォールバック）。

### A-4. `doom-font "Fira Code"` が可変フォント（VariableFont）で `:weight semi-light` が効かない可能性

インストール済みは `FiraCode-VariableFont_wght.ttf`（単一の可変フォント）。
Emacs 29 の可変フォント対応は限定的で、`(font-spec :weight 'semi-light)` は
無視されて既定インスタンス（Regular）で描画されることが多い。意図した細さにならない。

```elisp
;; 現状
(setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 16))
```

**対応のいずれか**:
- 静的ウェイト版 Fira Code を入れる（`brew install --cask font-fira-code`）。`:weight` が効く。
- 既にある `JetBrainsMono`（Light/Medium）に変更するなら
  `(font-spec :family "JetBrains Mono" :size 16 :weight 'medium)`。
- **D-5 のプログラミング＋日本語 複合フォント**へ移行（A-3/A-4/A-5/D-4 を一括で解決）。

### A-5. CJK（日本語）フォントが未設定

日本語で Org/メモを多用しているのに、`config.el` は ASCII フォントしか指定していない。
mac では Hiragino に暗黙フォールバックして一応表示されるが、
**Org テーブルの罫線ズレ・行高の乱れ・全角/半角幅の不整合**が起きやすい。

```elisp
;; config.el に追記（doom-font 設定の後ろ）
(defun my/setup-cjk-font ()
  (dolist (charset '(kana han cjk-misc bopomofo japanese-jisx0208))
    (set-fontset-font t charset (font-spec :family "BIZ UDGothic"))))  ; 実在フォント
(add-hook 'after-setting-font-hook #'my/setup-cjk-font)
(my/setup-cjk-font)
```

`BIZ UDGothic` は等幅性が高く、ASCII 2 : CJK 1 の幅比になりやすい。
`Hiragino Sans` / `Noto Sans CJK JP` でも可。
**D-5（複合フォント）を採用する場合はこの設定は不要**（1 フォントで CJK まで賄える）。

### A-6. `org-agenda-files` を起動のたびに再帰スキャンしている

`config.el`:

```elisp
(when (file-directory-p org-directory)
  (setq org-agenda-files (directory-files-recursively org-directory "\\.org$")))
```

- `config.el` ロード時（＝毎起動）に `~/org/` 以下の**全 `.org` を再帰列挙**する。
  ファイルが増える・`archive/` や添付が混ざると、起動と `org-agenda` 生成が両方遅くなる。
- アーカイブ済みタスクまで agenda 対象になり、agenda が汚れる。

**推奨**:

```elisp
;; 案1: ディレクトリを渡してトップレベルだけ対象に（サブは含めない）
(setq org-agenda-files (list org-directory))

;; 案2: 再帰は維持しつつ archive/ 等を除外
(when (file-directory-p org-directory)
  (setq org-agenda-files
        (seq-remove (lambda (f) (string-match-p "/\\(archive\\|attach\\|\\.stversions\\)/" f))
                    (directory-files-recursively org-directory "\\.org$"))))

;; 案3: agenda 対象を明示リストで管理（最速・最も予測可能）
(setq org-agenda-files (mapcar (lambda (f) (expand-file-name f org-directory))
                               '("tasks.org" "todo.org" "projects.org")))
```

日課管理が `tasks.org` / `todo.org` 中心なら **案3** が最も軽く確実。

### A-7. `(auto-save-visited-mode -1)` は冗長（死に設定）

`auto-save-visited-mode` は既定で無効。Doom もこれを有効化していないため、
`-1` で無効化する意味がない。トップレベルでの呼び出しも中途半端。
→ **行ごと削除**でよい。`#file#` 形式の自動保存を止めたいなら別物で、
`(setq auto-save-default nil)` を使う（ただし安全網が減るので非推奨）。

### A-8. Symbola フォント欠如（doom doctor 警告）

> Failed to locate the 'Symbola' font. … render failure can crash Emacs / cause slowdowns.

絵文字や記号のグリフが無いフォントにフォールバックすると描画失敗〜稀にクラッシュ要因。
`Symbols Nerd Font Mono` は入っているので実害は小さいが、保険として:

```sh
brew install --cask font-symbola
```

または `config.el` で明示フォールバック:

```elisp
(set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono") nil 'append)
(set-fontset-font t 'emoji  (font-spec :family "Apple Color Emoji") nil 'prepend)
```

---

## B. パフォーマンス・環境（優先度: 中〜高）

> **実施状況（2026-09-10）**
> - **B-1** ✅ **完了（2026-09-11、ユーザーが emacs-plus@30 導入 → 発生したエラーを解決）**。
>   `brew install emacs-plus@30` 後、初回起動で
>   `⛔ Error (doom-after-init-hook): … (void-variable doom-modules)` が発生。
>   原因は **Emacs バイナリを切り替えた後に `doom sync` を実行しておらず**、
>   プロファイルローダ（`~/.local/share/doom/profiles.el`・`init.30.2.el` 等、バージョン別に生成される）が
>   29.4 時点のまま残っていたため、Doom のコア初期化が完走せず `doom-modules` が未束縛のまま
>   `doom-after-init-hook` に到達していたこと。
>   **対応**: `doom sync -!`（`-!` = 確認プロンプトを自動承認）を実行 → 176 パッケージの再チェックと
>   `init.30.2.el` の再生成が完了。デーモン起動で `doom-modules` が正しく束縛（43 モジュール）され、
>   エラー・警告なしを確認。初回起動はネイティブコンパイルのため 12.5s だったが、2 回目は
>   **0.64s**（旧 29.4 時代の 0.70〜0.77s より高速化）。
>   ※ 一度 `--aot`（全パッケージ事前ネイティブコンパイル）付きで試したところ 1365 ファイルの
>   コンパイルで 10 分超かかり中断。`--aot` は不要（未コンパイル分は Emacs 30 が使用時に非同期で
>   自動コンパイルする）。**教訓: Emacs バイナリを切り替えたら必ず `doom sync` を実行する**
>   （`doom sync` のヘルプにも「6. Up or downgrade Emacs itself」で明記されている）。
> - **B-2** ✅ **完了**。`config.el` の再帰スキャンを**明示リスト管理**に変更
>   （`tasks.org` / `todo.org` / `habits.org` / `journal.org` / `mylife/plan/`（ディレクトリ）/
>   `study/strategy.org` / `study/university/semester3/{assignment,final_exam}.org` / `semester4/plan.org`）。
>   `seq-filter #'file-exists-p` で欠損に強くしてある。`~/org` が iCloud シンボリックリンク（37 ファイル）だったため効果は大きい。
> - **B-3** ✅ **完了**。`doom gc` 実行 → **回収対象なし**（孤立パッケージ・古い ELN 無し）。
>   `.local/straight` の 344MB は 174 パッケージの正規実体で、ムダではないと確認。以後もモジュール増減後に `doom gc`。
> - **B-4** ✅ **ベースライン計測完了**。デーモン計測で `emacs-init-time` = **0.77s**、
>   Doom カウンタ「174 packages / 43 modules / ~1.0s」、init 中 GC 2 回のみ。手段は B-4 節に更新。
> - **B-5** ⬜ 未対応（好み。現状維持で可）。
>
> **副次的に発覚**: デーモン起動時に `[yas] yas-snippet-dirs: ~/.config/doom/snippets/ is not a directory` の警告。
> `snippets` モジュールが私用スニペット置き場を探すが未作成なだけ。実害なし。
> 消すなら `mkdir -p ~/.config/doom/snippets`。

### B-1. Emacs 29.4 → 30.2 へアップグレード

```sh
brew install emacs-plus@30 --with-imagemagick --with-mailutils
# native-comp は @30 では必須依存（libgccjit/gcc）なのでフラグ不要
# 切り替え（@29 は消さない）:
brew unlink emacs-plus@29 && brew link --overwrite emacs-plus@30
# 元に戻したくなったら: brew unlink emacs-plus@30 && brew link emacs-plus@29
```

Emacs 30 の主な恩恵（Doom は 30 を完全サポート）:

- **Org 9.7 同梱**（現状 29.4 は 9.6 系）。LaTeX プレビュー・エクスポート周りの改善、
  `org-latex-preview` 系の改良が入りやすい（C-2 と関連）。
- native-comp / JIT の高速化、`completion-preview-mode`、長い行の描画改善。
- `use-package` の `:vc`、`package-vc-install`、`M-x` の精度向上、`pixel-scroll-precision` 改善。
- tree-sitter（`treesit`）の API 拡充・安定化。

アップグレード後は `doom sync` → 初回起動でネイティブ再コンパイル（数分、以降は速い）。

### B-2. `org-agenda-files` の再帰スキャン限定（= A-6。✅ 実施済み）

`config.el` を明示リスト管理へ変更済み（上の実施状況ブロック参照）。
起動時の `directory-files-recursively`（iCloud 上 37 ファイル走査）が無くなり、
agenda 生成も対象 9 ファイル前後に限定された。新規ファイルはリストに追記して運用。

### B-3. straight ディレクトリの整理（✅ 実施済み）

```sh
~/.config/emacs/bin/doom gc      # 孤立パッケージ／古い ELN の回収 → 今回は対象なし
~/.config/emacs/bin/doom sync -u # モジュール変更後・アップグレード後に実行
```

`.local/straight` の 344MB は 174 パッケージの正規実体。肥大ではない。
モジュールを削除したときだけ `doom gc` で効果が出る。

### B-4. 起動時間の可視化手段（✅ ベースライン取得済み）

**今回のベースライン**: `emacs-init-time` = **0.77s** / Doom カウンタ **~1.0s** / init 中 GC 2 回。

- **総時間**: `M-x emacs-init-time`。Doom は起動直後に `*Messages*` へ
  「Doom loaded N packages across M modules in X.XXXs」も出す。
- **CLI で毎回同条件で測る**（このベースラインもこの方法）:
  ```sh
  emacs --daemon=bench 2>&1 | grep -i "Doom loaded"
  emacsclient -s bench -e '(emacs-init-time)'
  emacsclient -s bench -e '(kill-emacs)'
  ```
- **内訳が見たいとき**: `M-x doom/toggle-profiler`（ネイティブ profiler の開始／レポート）。
  ※ これは「起動後の実行時プロファイル」なので、起動そのものの内訳には
  `packages.el` に `(package! benchmark-init)` を足し、`$DOOMDIR/init.el` の**冒頭**で
  `(require 'benchmark-init)` → `(benchmark-init/activate)` する（Doom では読み込みが遅いと
  取りこぼすので init.el 冒頭必須）。`M-x benchmark-init/show-durations-tree` で確認。
- モジュール増減の前後で比較する運用にすると重い追加にすぐ気づける（nvim の `:StartupTime` 相当）。

### B-5. `+smartparens` の是非（好み）

`(default +bindings +smartparens)` の `+smartparens` は、大きなファイルや特定の
メジャーモードで入力遅延・意図しないペア挿入の原因になることがある。
Lisp 以外で恩恵が薄いと感じるなら `+smartparens` を外し、組み込みの
`electric-pair-mode`（Doom が代替で有効化）に任せる選択肢がある。現状維持でも問題はない。

---

## C. 古い書き方・非推奨・改善余地（優先度: 中）

> **実施状況（2026-09-11）: C-1〜C-3 対応完了。想定より大きな実害が見つかったため、
> 当初案（named 関数化＋lualatex パイプライン追加）から踏み込んで、
> プレビュー方式そのものを置き換えた。**
>
> **調査で判明した実際の挙動**（`emacs --batch` で `org-create-formula-image` を直接実行し、
> 実際の TeX ログとレンダリング画像で確認）:
> - 旧方式（`dvisvgm` = 素の `latex` で DVI 生成）は、**通常の数式フラグメントは問題なく動く**。
>   旧 advice（`org-latex-compiler` を一時的に "pdflatex" 扱いにする）は、
>   ユーザーの実ファイル（`math.org`、`#+LATEX_COMPILER:` の明示指定なし）に対しては
>   正しく機能しており、fontspec 混入によるクラッシュは**現状では起きていなかった**。
> - ただし **フラグメントの中に日本語などの非ASCII文字を書くと、エラーにならず
>   その文字だけ無言で欠落する**（素の `latex` に CJK 対応が無いため）。
>   例: `$v = \text{速度}$` を旧方式でプレビューすると「速度」の部分が消える。
>   現在の `math.org` にはこのパターンは無い（0件）が、数式に日本語ラベルを
>   混ぜる書き方は今後増えうるため、静かな文字化けは早めに潰しておく価値がある。
> - **対応**: プレビューを **lualatex(PDF) + luatexja + `dvisvgm --pdf`** の方式に統一。
>   これにより日本語混じりの数式も正しく描画され、しかも `org-latex-compiler` の値に
>   一切依存しなくなるため、**C-1 の advice（コンパイラのすり替え）自体が丸ごと不要になった**
>   （パッチではなく削除で解決）。
> - **前提ツールを新規導入**: `brew install dvisvgm mupdf-tools`。
>   TeX Live 同梱の `dvisvgm`（`/Library/TeX/texbin/dvisvgm`）は `--pdf`（PDF入力）に
>   非対応気味で、luatexja は **DVI 出力を許さない**（`Package luatexja Error: DVI output
>   is not supported`）ため、PDF 経由が必須。Homebrew 版 `dvisvgm` の `--pdf` は
>   Ghostscript 10.01 以降と非互換のため `mutool`（mupdf-tools）を併用させている。
>   `/opt/homebrew/bin/dvisvgm` が `/Library/TeX/texbin/dvisvgm` より `PATH` で
>   優先されることを確認済み。
> - **検証**: 実ファイル `~/org/study/record/math.org` を対象に、
>   (1) 通常の数式（`$E=mc^2$`）、(2) 積分・総和・分数を含む複雑な式、
>   (3) 日本語混在（`$v=\text{速度}$`）の3パターンで実際に SVG を生成し、
>   PNG化して目視確認。すべて正しくレンダリングされることを確認済み
>   （日本語部分は TeX Live 同梱の HaranoAji Mincho フォントで自動描画）。
> - **C-2**（新しい `org-latex-preview` プレビューエンジン）は、Emacs 30.2 + Org 9.8.6
>   （Doom が pin している最新版）で調べた限り **まだ upstream に無い**
>   （`org-latex-preview-process-alist` 等の変数が存在しない）。
>   引き続き `org-preview-latex-process-alist`（旧API）を使う設計のままで正しい。
>   upstream にマージされ次第、再検討する。

### C-1. LaTeX プレビューの `advice-add` ハックは脆い（→ C-3 の対応で丸ごと不要に）

`config.el`:

```elisp
(advice-add 'org-create-formula-image :around
            (lambda (fn &rest args)
              (let ((org-latex-compiler "pdflatex"))
                (apply fn args))))
```

fontspec が `latex`/`pdflatex` プレビューに混入する問題への対症療法だが、

- `org-create-formula-image` の内部仕様変更で黙って壊れる。
- 匿名ラムダなので `advice-remove` しづらい（デバッグ時に外せない）。

**✅ 対応済み**: C-3 でプレビュー方式自体を lualatex(PDF)+luatexja に置き換えたため、
`org-latex-compiler` を偽装する必要がなくなり、この advice は**削除**した
（named 関数化して残す、ではなく丸ごと撤去）。

### C-2. `org-latex-preview`（新プレビューエンジン）への移行を視野に

**◐ 現時点では見送り（調査済み）**。Org 9.7 以降で新しいインライン・自動更新の
プレビューエンジンが提案されているという情報を基に検討していたが、
実機（Emacs 30.2 + Doom が pin する Org **9.8.6**）で確認したところ
`org-latex-preview-process-alist` 等の新API は**まだ存在しない**
（`org-latex-preview` という関数名自体は昔からある「フラグメント表示トグル」コマンドで、
新エンジンとは別物）。旧来の `org-preview-latex-process-alist` ベースのままで
現状は正しい。upstream にマージされたら改めて検討する。

### C-3. プレビューコンパイラの日本語対応（✅ 対応済み・実害を確認して修正）

**実機検証の結果**: 当初「pdflatex 固定が ltjsarticle/bxjsarticle で破綻する」と
想定していたが、実際には旧 advice は現状のユーザーファイル（`#+LATEX_COMPILER:` の
明示指定なし）に対しては正しく機能しており、フォント指定のクラッシュ自体は
起きていなかった。一方で **`org-create-formula-image` を実ファイルに対して直接実行し、
生成された SVG を画像化して目視確認**したところ、別の実害を発見した:

> **数式フラグメントの中に日本語などの非ASCII文字を書くと、エラーにならずその文字だけ
> 無言で欠落する。** 素の `latex`（DVI エンジン）には CJK 対応が無いため。
> 例: `$v = \text{速度}$` → 「速度」の部分だけ消えた画像が生成される。

**対応**: プレビューを **lualatex(PDF) + luatexja + `dvisvgm --pdf`** に統一。

```elisp
(after! org
  ;; luatexja は DVI 出力を許さない（"DVI output is not supported" で落ちる）ため、
  ;; dvilualatex 経由の DVI ではなく lualatex の PDF 出力 + dvisvgm --pdf を使う。
  (add-to-list 'org-preview-latex-process-alist
               '(dvisvgm-lua
                 :programs ("lualatex" "dvisvgm")
                 :description "pdf > svg (lualatex + luatexja, 日本語対応)"
                 :image-input-type "pdf" :image-output-type "svg"
                 :image-size-adjust (1.7 . 1.5)
                 :latex-header "\\documentclass{article}
\\usepackage[usenames]{color}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\usepackage{luatexja}
\\pagestyle{empty}
\\setlength{\\textwidth}{\\paperwidth}
\\addtolength{\\textwidth}{-3cm}
\\setlength{\\oddsidemargin}{1.5cm}
\\addtolength{\\oddsidemargin}{-2.54cm}
\\setlength{\\evensidemargin}{\\oddsidemargin}
\\setlength{\\textheight}{\\paperheight}
\\addtolength{\\textheight}{-\\headheight}
\\addtolength{\\textheight}{-\\headsep}
\\addtolength{\\textheight}{-\\footskip}
\\addtolength{\\textheight}{-3cm}
\\setlength{\\topmargin}{1.5cm}
\\addtolength{\\topmargin}{-2.54cm}"
                 :latex-compiler ("lualatex -interaction nonstopmode -output-directory %o %f")
                 :image-converter ("dvisvgm --pdf %f --no-fonts --exact-bbox --scale=%S --output=%O")))
  (setq org-preview-latex-default-process 'dvisvgm-lua))
```

**前提ツール**（導入済み）: `brew install dvisvgm mupdf-tools`。
TeX Live 同梱の `dvisvgm` は `--pdf`（PDF入力モード）が使えなかったため Homebrew 版に切替え。
Homebrew 版 `dvisvgm` の `--pdf` は Ghostscript 10.01 以降と非互換なので、
代わりに `mutool`（mupdf-tools）を自動的に使わせている。
`which -a dvisvgm` で `/opt/homebrew/bin/dvisvgm` が `/Library/TeX/texbin/dvisvgm` より
先に来ることを確認済み。

### C-4. `map!` の `:localleader` / `:leader` は良い書き方

`config.el` の pomodoro バインドや capture テンプレートの追記は Doom の作法通りで問題なし。
`(setq org-capture-templates (append org-capture-templates '(...)))` も可。
ただ `org-capture-templates` は `after! org` の外でも `add-to-list` で足せるので、
好みで `(after! org)` の外に出して見通しを良くしてもよい（機能差はなし）。

---

## D. モジュール／パッケージの代替・追加提案（優先度: 中〜低）

> `init.el` の `doom!` ブロックのフラグ調整が中心。変更後は必ず `doom sync` → Emacs 再起動。

| # | 現状 | 提案 | 理由 |
|---|---|---|---|
| D-1 | `:lang latex` **無効** | `(latex +latexmk +cdlatex +fold)` を有効化 | Org の数式入力（`org-cdlatex-mode`）・latexmk・プレビュー枠が激変。LaTeX ログ格闘の根治 |
| D-2 | `:lang org`（フラグ無し）＋ `package! org-download` を手動追加 | `(org +dragndrop +pretty)` | `+dragndrop` が org-download を同梱・設定（クリップボード画像貼付）。手動 `package!` と hook を撤去できる。`+pretty` で見出し等の整形 |
| D-3 | `:editor format` **無効**（`SPC l f` に手動 `lsp-format-buffer`） | `(format)` を有効化（`+onsave` は好みで） | apheleia による**非同期**整形。`SPC c f` = `+format/buffer` が eglot 経由でも動く。A-2 を根治 |
| D-4 | `:completion (corfu +orderless) vertico` | `(corfu +icons +orderless +dabbrev) (vertico +icons)` | 補完メニュー／ミニバッファに nerd-icons。`Symbols Nerd Font Mono` は導入済み |
| D-5 | ASCII フォントと CJK フォントを別管理（未設定） | **プログラミング＋日本語 複合 Nerd Font** に一本化 | `PlemolJP Console NF` / `HackGen Console NF` / `Moralerspace`（いずれも Nerd Font 同梱・全角半角 2:1）。A-3/A-4/A-5/D-4 を 1 フォントで解決 |
| D-6 | `svelte-mode`（やや古い、hook が壊れ） | hook を `lsp!` に（A-1）。`svelte-language-server` を pnpm で導入。将来 `svelte-ts-mode` も検討 | LSP が実際に動くようにする |
| D-7 | `:lang python +lsp`（pyright 使用、`ruff` 無し） | `ruff` を導入し apheleia の `ruff`/`ruff-isort` で整形、flymake で lint。`basedpyright` への差し替えも検討 | `uv` 運用と相性良。black より高速、lint と整形を一本化 |
| D-8 | `:input japanese`（`cmigemo` 欠如で migemo 不動） | `brew install cmigemo` | ローマ字で日本語をインクリメンタル検索（vertico/consult 連携）。日本語多用なら効果大 |
| D-9 | `:tools magit`（フラグ無し） | GitHub の PR/Issue を Emacs で扱うなら `(magit +forge)` | forge で PR レビュー・issue 操作。使わないなら不要 |
| D-10 | `:term` 何も無効 | Emacs 内ターミナルが要るなら `(vterm)` | 最速の端末エミュ（`cmake` + `libvterm` 必要）。外部端末派なら現状維持で可 |
| D-11 | `:lang javascript +lsp`（LSP サーバ未導入） | `pnpm add -g typescript typescript-language-server` | 導入しないと JS/TS で LSP が一切効かない。Deno プロジェクトなら `deno lsp`（導入済み） |
| D-12 | `:checkers syntax` のみ | 英文を書くなら `(spell +flyspell)` か `(spell +aspell)` | Org/Markdown の英語スペルチェック。日本語主体なら優先度低 |

### D-1 補足: `:lang latex` を入れても Org と競合しない

`:lang latex` は AUCTeX / CDLaTeX / latexmk / preview を持ち込むだけで、`:lang org` の
LaTeX エクスポート設定（`config.el` の `after! ox-latex` ブロック）はそのまま生きる。
`+cdlatex` を入れると Org バッファで `org-cdlatex-mode` が使え、`` `a `` → `\alpha`、
`_` `^` の自動 `{}` など数式入力が高速化する（`org-cdlatex-mode` を org-mode-hook に足す）。

### D-5 補足: 複合フォント例（採用する場合の `config.el`）

```elisp
;; 例: PlemolJP Console NF（brew install --cask font-plemol-jp-nf 等で導入）
(setq doom-font (font-spec :family "PlemolJP Console NF" :size 15)
      doom-variable-pitch-font (font-spec :family "PlemolJP" :size 15)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono"))
;; CJK は複合フォントが賄うので set-fontset-font は不要
```

`HackGen Console NF` / `Moralerspace Argon NF` も同系統。いずれも全角半角 2:1 で
Org テーブルが崩れず、アイコン（Nerd Font）も同一フォントで出る。

---

## E. QoL・細かい設定提案

- **`user-full-name` / `user-mail-address` を設定**（`config.el` 冒頭のコメントアウトを解除）。
  magit のコミット、file-templates、snippets の `` `user-full-name` `` 展開で使われる。
  ```elisp
  (setq user-full-name "NekoFukurouInu"
        user-mail-address "tinyowl168@gmail.com")
  ```
- **`display-line-numbers-type`**: 現状 `t`（絶対）。evil なら `'relative`（相対）が
  `d3j` などのモーションと相性良い。Org/PDF など散文では Doom が自動で切るが、
  気になるなら `(setq display-line-numbers-type 'relative)`。
- **markdown コンパイラ**: `brew install pandoc`（doom doctor 警告の解消。`markdown-preview` や
  エクスポートで使う）。
- **`shellcheck`**: `brew install shellcheck`（`:lang sh` の lint）。
- **`org-log-done 'time` は良い設定**。加えて `(setq org-log-into-drawer t)` にすると
  `:LOGBOOK:` ドロワーにまとまって見た目が締まる。
- **`org-habit`**: `(setq org-habit-graph-column 60)` 程度にしておくと agenda 幅で崩れにくい。
- **`SPC l f` の後始末**: A-2 の通り削除。整形は `SPC c f`（D-3）へ。

---

## F. 小ネタ

- **`~/.config/doom` が git 管理外**。nvim が `~/dotfiles/.config/nvim` 配下なのに対し、
  Doom 設定はバージョン管理されていない。dotfiles に取り込むか `git init` して履歴を残す。
  併せて `.gitignore` に `.DS_Store` と後述のログを追加。
- **`emacs-org-latex-log.txt` が設定ディレクトリに置きっぱなし**。デバッグ用の吐き出しログ。
  `agent/` かどこかに退避、または削除して `.gitignore` へ。
- **`doom doctor` の残り警告**（stylelint / js-beautify / pipenv / pytest / nosetests）は、
  該当言語で lint/テストを実際に使うときだけ導入すればよい（web を触らないなら無視可）。
  Python テストを Emacs から回すなら `uv tool install pytest` 相当。
- **`pyright` の管理**: `uv tool install pyright`（または `basedpyright`）に寄せると
  Node 依存をプロジェクトから切り離せる。
- **`doom upgrade` の頻度**: Doom 本体は 2〜3 か月に一度で十分。`doom sync` はこまめに。
- **`treesit` の文法**: `libtree-sitter-python/rust.dylib` は自動ビルド済み。新しい言語を
  `+tree-sitter` で足したら `M-x treesit-install-language-grammar` か Doom が自動取得。
- **構造編集が欲しくなったら**: Doom の tree-sitter モジュールは `combobulate` /
  `evil-textobj-tree-sitter` をコメントアウトで同梱していない。`packages.el` に
  `(package! evil-textobj-tree-sitter)` を足すと `vaf`/`vif`（関数）等の TS テキストオブジェクトが使える。

---

## 外部ツール導入リスト

| ツール | コマンド | 用途 | 優先 |
|---|---|---|---|
| cmigemo | `brew install cmigemo` | 日本語ローマ字検索（`:input japanese`） | 高 |
| Emacs 30 | `brew install emacs-plus@30 --with-native-comp` | 本体アップグレード（B-1） | 高 |
| ruff | `uv tool install ruff` | Python lint + 整形（D-7） | 中 |
| typescript-language-server | `pnpm add -g typescript typescript-language-server` | JS/TS の LSP（D-11） | 中（web を使うなら高） |
| pandoc | `brew install pandoc` | markdown 変換（doom doctor） | 中 |
| texlab | `brew install texlab` | LaTeX の LSP（`:lang latex +lsp` を足す場合） | 中 |
| フォント | `brew install --cask font-plemol-jp-nf`（or font-fira-code / font-fira-sans / font-symbola） | フォント整合（A-3〜A-5, D-5） | 中 |
| shellcheck | `brew install shellcheck` | シェルスクリプト lint | 低 |
| svelte-language-server | `pnpm add -g svelte-language-server` | `.svelte` の LSP（D-6） | 低（svelte を書くなら） |
| basedpyright | `uv tool install basedpyright` | pyright の上位互換（任意） | 低 |

---

## 推奨着手順

1. **A-1 / A-2**（eglot と lsp-mode 関数の不整合）を修正。`svelte-mode` の hook を `lsp!` に、
   `SPC l f` の `map!` を削除。→ 実害のあるバグなので最優先。
2. **A-6 / B-2**（`org-agenda-files`）を案 1〜3 のいずれかに変更。起動と agenda が軽くなる。
3. **A-7**（`auto-save-visited-mode` の行）削除、**A-8**（Symbola / 記号フォールバック）対応。
4. **外部ツール**: `brew install cmigemo pandoc shellcheck` をまとめて。`uv tool install ruff`。
5. **D-3**（`:editor format` 有効化）→ `doom sync` → `SPC c f` で整形が動くことを確認。A-2 の代替が完成。
6. **フォント整理**: 当面は A-3/A-4/A-5 の最小修正（実在フォント指定＋CJK フォントセット）。
   腰を据えるなら **D-5 の複合 Nerd Font** に乗り換え（`config.el` のフォント 3 行を差し替え、
   `set-fontset-font` は削除、`:completion` に `+icons`）。
7. **B-1**: Emacs 30 へアップグレード → `doom sync` → 初回再コンパイルを待つ → 動作確認。
8. **D-1 / D-2**（`:lang latex` と `:lang org +dragndrop +pretty`）を `init.el` に足して `doom sync`。
   `org-download` の手動 `package!` / hook を撤去。`org-cdlatex-mode` を試す。
9. **C-3**（プレビューを lualatex+dvisvgm パイプラインに）→ 安定したら **C-1** のアドバイス削除。
   Emacs 30 化後に **C-2**（`org-latex-preview`）をその時点の Org バージョンで検討。
10. **F**: `~/.config/doom` を dotfiles / git 管理へ。`emacs-org-latex-log.txt` を退避、`.gitignore` 整備。
11. 余力で **D-4 以降**（icons / magit +forge / vterm / spell / TS サーバ）を必要に応じて。
