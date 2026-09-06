return {
	"lervag/vimtex",
	-- lazy = false を外し ft 遅延に。Neovim 0.12 は .tex を builtin で filetype=tex 判定するので
	-- FileType tex で読み込まれる。init（vim.g.vimtex_*）は読み込み前に走る必要があるので残す。
	ft = { "tex", "plaintex" },
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_compiler_latexmk = {
			out_dir = "build",
		}
		-- latexmk のエンジン指定フラグは options とは別に vimtex が末尾へ自動付与する。
		-- マジックコメント無しのファイルでは既定キー "_" (= "-pdf") が使われ pdflatex に
		-- なるので、"_" を "-lualatex" に上書きして全ファイルを LuaLaTeX でビルドさせる。
		vim.g.vimtex_compiler_latexmk_engines = {
			["_"] = "-lualatex",
		}
		-- ハイライトは treesitter(latex) に任せる → vimtex の構文機能を無効化し
		-- 「Syntax highlighting is controlled by Treesitter!」の通知を消す
		vim.g.vimtex_syntax_enabled = 0
	end,
}
