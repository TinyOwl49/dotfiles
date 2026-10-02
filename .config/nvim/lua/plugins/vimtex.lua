return {
	"lervag/vimtex",
	ft = { "tex", "plaintex" },
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_compiler_latexmk = {
			out_dir = "build",
		}
		-- ~/.latexmkrc が $pdf_mode = 3 (platex→dvipdfmx) を指定しているため、
		-- VimTeX はエンジンを "pdfdvi" と判定してしまう。
		-- pdfdvi/pdflatex/pdfps いずれに転んでも lualatex を使うよう全部潰す。
		-- ※ この Neovim で開く .tex は原則 lualatex でコンパイルされる。
		--    platex で組みたいファイルは先頭に `% !TEX program = platex` を書いて上書きする。
		vim.g.vimtex_compiler_latexmk_engines = {
			["_"] = "-lualatex",
			["pdfdvi"] = "-lualatex",
			["pdflatex"] = "-lualatex",
			["pdfps"] = "-lualatex",
			["luatex"] = "-lualatex",
			["lualatex"] = "-lualatex",
			["xelatex"] = "-xelatex",
		}
		-- ハイライトは treesitter(latex) に任せる
		vim.g.vimtex_syntax_enabled = 0
	end,
}
