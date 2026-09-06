-- Haskell: haskell-tools.nvim manages HLS itself.
-- HLS is the one installed via ghcup (~/.ghcup/bin/haskell-language-server-wrapper).
-- Do NOT install haskell-language-server through Mason, and do NOT call
-- lspconfig.hls.setup() anywhere -- that would attach HLS twice.
return {
	"mrcjkb/haskell-tools.nvim",
	version = "^10", -- v10: Neovim 0.12+ 前提（現在 0.12.5）。旧 v4 ピンを解除
	-- lazy=false は外した。Neovim 0.12 は .hs/.lhs/.cabal を builtin で判定するので ft 遅延で動く。
	-- init（vim.g.haskell_tools 設定）は lazy でも起動時に走る。
	ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
	init = function()
		vim.g.haskell_tools = {
			hls = {
				-- v10 は blink.cmp / nvim-cmp を自動検出して capabilities を付与するため明示不要
				on_attach = function(_, bufnr)
					local ht = require("haskell-tools")
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
					end

					map("<leader>hh", ht.hoogle.hoogle_signature, "Haskell: Hoogle 検索(シグネチャ)")
					map("<leader>he", ht.lsp.buf_eval_all, "Haskell: eval コメントを全評価")
					map("<leader>hr", ht.repl.toggle, "Haskell: GHCi REPL 切替(パッケージ)")
					map("<leader>hR", function()
						ht.repl.toggle(vim.api.nvim_buf_get_name(bufnr))
					end, "Haskell: GHCi REPL 切替(このファイル)")
					map("<leader>hq", vim.lsp.codelens.run, "Haskell: コードレンズ実行(hlint 等)")
				end,
			},
		}
	end,
}
