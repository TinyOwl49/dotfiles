return {
	"lervag/vimtex",
	ft = { "tex", "plaintex" },
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_compiler_latexmk = {
			out_dir = "build",
		}
		vim.g.vimtex_compiler_latexmk_engines = {
			["_"] = "-lualatex",
		}
		-- ハイライトは treesitter(latex) に任せる 
		vim.g.vimtex_syntax_enabled = 0
	end,
}
