;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; code = Fira Code。`:weight` は付けない（A-4）。
;;   インストール済みが可変フォント単体（FiraCode-VariableFont_wght.ttf）で、
;;   Emacs 29 では `semi-light` 等の指定が効かず既定インスタンスになるため、
;;   指定しても誤解を生むだけ。細くしたいなら静的ウェイト版を別途入れる。
;; variable-pitch = Hiragino Sans（A-3）。
;;   Fira Sans は Black ウェイトしか入っておらず、可変ピッチ表示（Org 見出し・Help 等）が
;;   すべて極太になっていた。Hiragino Sans は macOS 標準で日本語もそのまま綺麗。
(setq doom-font (font-spec :family "Fira Code" :size 16)
      doom-variable-pitch-font (font-spec :family "Hiragino Sans" :size 16))

;; フォント確定後に呼ばれる。日本語(CJK)フォントと記号・絵文字フォールバックを明示する。
;; daemon では最初のフレーム生成時にも発火するので display-graphic-p でガード。
(defun my/setup-fonts ()
  (when (display-graphic-p)
    ;; A-5: CJK は BIZ UDGothic（インストール済み・等幅性が高く Org テーブルが崩れにくい）。
    ;;      Hiragino Sans / Noto Sans CJK JP にしたければ family を差し替える。
    (dolist (charset '(kana han cjk-misc bopomofo japanese-jisx0208))
      (set-fontset-font t charset (font-spec :family "BIZ UDGothic")))
    ;; A-8: 記号・絵文字のフォールバック（Symbola 未導入の代替。'append で最低優先度）。
    (set-fontset-font t 'symbol (font-spec :family "Symbols Nerd Font Mono") nil 'append)
    (set-fontset-font t 'emoji  (font-spec :family "Apple Color Emoji") nil 'append)))
(add-hook 'after-setting-font-hook #'my/setup-fonts)
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/"
      org-daily-tasks-file (expand-file-name "tasks.org" org-directory))

;; agenda 対象は明示管理する。~/org/ 以下を毎回再帰スキャンすると、
;; iCloud 上の 37 ファイル（templates/ や study/ の記録ノート含む）まで
;; 解析対象になり、起動と agenda 生成が遅くなるため。
;; 新しく agenda に載せたいファイル／ディレクトリはこのリストに足す。
;; （ディレクトリを指定するとその直下の *.org が対象。再帰はしない）
(setq org-agenda-files
      (seq-filter #'file-exists-p
                  (mapcar (lambda (p) (expand-file-name p org-directory))
                          '("tasks.org"
                            "todo.org"
                            "habits.org"
                            "journal.org"
                            "mylife/plan"                        ; 直下の *.org
                            "study/strategy.org"
                            "study/university/semester3/assignment.org"
                            "study/university/semester3/final_exam.org"
                            "study/university/semester4/plan.org"))))

(after! org
  (require 'org-habit)

  (setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)")))
  (setq org-log-done 'time)

  (defun my/org-goto-todays-daily-task-headline ()
    "tasks.org 内で今日の日付の見出しを探し、無ければファイルの先頭に作成してその位置に移動します。"
    (goto-char (point-min))
    (let ((today-str (format-time-string "%Y/%m/%d")))
      (if (re-search-forward (concat "^\\*+ +" (regexp-quote today-str)) nil t)
          (beginning-of-line)
        (goto-char (point-min))
        (insert (format-time-string "* %Y/%m/%d (%a) [/]\n\n"))
        (forward-line -2))))

  (defun my/org-open-todays-tasks ()
    "今日の Daily Task セクション（なければ作成）へ直接ジャンプして開く関数"
    (interactive)
    (find-file org-daily-tasks-file)
    (my/org-goto-todays-daily-task-headline))

  (setq org-capture-templates
        (append org-capture-templates
                '(("d" "Daily Task" entry
                   (file+function org-daily-tasks-file my/org-goto-todays-daily-task-headline)
                   "** TODO %?\n"
                   :empty-lines 0)
                  ("i" "Inbox" entry
                   (file+headline "todo.org" "Inbox")
                   "** TODO %?\n%a"
                   :prepend t
                   :empty-lines 1))))


;   (setq org-latex-compiler "lualatex")
;   (setq org-latex-pdf-process
;         '("latexmk -f -pdf -%latex -interaction=nonstopmode -output-directory=%o %f"))
;   (add-to-list 'org-latex-classes
;                '("ltjsarticle"
;                  "\\documentclass{ltjsarticle}
; [DEFAULT-PACKAGES]
; [PACKAGES]
; [EXTRA]"
;                  ("\\section{%s}" . "\\section*{%s}")
;                  ("\\subsection{%s}" . "\\subsection*{%s}")
;                  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
;                  ("\\paragraph{%s}" . "\\paragraph*{%s}")
;                  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
;
;   (setq org-latex-default-class "ltjsarticle"))
  ;; プレビュー(C-c C-x C-l)の LaTeX フラグメントを lualatex + dvisvgm でコンパイルし、
  ;; SVG 画像として表示する。既定の 'dvisvgm プロセスは内部で plain "latex" を使うため、
  ;; lualatex 前提のパッケージ（fontspec / luatexja 等）を使いたい場合はこちらが必要。
  ;; lualatex は `--output-format=dvi` で DVI を吐けるので、それを dvisvgm で SVG 化する。
  (add-to-list 'org-preview-latex-process-alist
               '(dvisvgm-lualatex
                 :programs ("lualatex" "dvisvgm")
                 :description "dvi > svg (lualatex)"
                 :message "you need to install the programs: lualatex and dvisvgm."
                 :image-input-type "dvi"
                 :image-output-type "svg"
                 :image-size-adjust (1.7 . 1.5)
                 :latex-compiler ("lualatex -output-format=dvi -interaction=nonstopmode -output-directory=%o %f")
                 :image-converter ("dvisvgm %f -n -b min -c %S -o %O")))
  (setq org-preview-latex-default-process 'dvisvgm-lualatex)
  ;; 数式プレビューが大きすぎたため、既定の :scale 1.0 から一回り縮小。
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.2)))

; (after! ox-latex
;   (setq org-latex-compiler "lualatex")
;
;   (setq org-latex-pdf-process
;         '("latexmk -f -lualatex -interaction=nonstopmode -output-directory=%o %f"))
;
;   ;; 日本語用クラス ltjsarticle の追加
;   (add-to-list 'org-latex-classes
;                '("ltjsarticle"
;                  "\\documentclass[11pt,a4paper]{ltjsarticle}
; [DEFAULT-PACKAGES]
; [PACKAGES]
; [EXTRA]"
;                  ("\\section{%s}" . "\\section*{%s}")
;                  ("\\subsection{%s}" . "\\subsection*{%s}")
;                  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
;                  ("\\paragraph{%s}" . "\\paragraph*{%s}")
;                  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
;
;   ;; 日本語用クラス bxjsarticle の追加
;   (add-to-list 'org-latex-classes
;                '("bxjsarticle"
;                  "\\documentclass[autodetect-engine,ja=standard]{bxjsarticle}
; [DEFAULT-PACKAGES]
; [PACKAGES]
; [EXTRA]"
;                  ("\\section{%s}" . "\\section*{%s}")
;                  ("\\subsection{%s}" . "\\subsection*{%s}")
;                  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
;                  ("\\paragraph{%s}" . "\\paragraph*{%s}")
;                  ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
;
;

(after! org-download
  (add-hook 'dired-mode-hook #'org-download-enable))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;; 整形は `SPC c f`（code → format）に集約する。
;; `lsp-format-buffer` は lsp-mode の関数で、この構成（`:tools lsp +eglot`）では
(autoload 'eglot-format "eglot" nil t)   ; eglot 未ロード時でもキーが有効になるように
(map! :leader :desc "Format buffer/region" "c f" #'eglot-format)


;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq delete-by-moving-to-trash t)

(use-package! svelte-mode
  :mode "\\.svelte\\'"
  :hook (svelte-mode . lsp!))

(after! web-mode
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t))

(use-package! org-pomodoro
  :after org
  :config
  (setq org-pomodoro-length 25
        org-pomodoro-short-break-length 5
        org-pomodoro-long-break-length 15
        org-pomodoro-long-break-frequency 4))

(map! :map org-mode-map
      :localleader
      :desc "Start/pause pomodoro" "u" #'org-pomodoro)
