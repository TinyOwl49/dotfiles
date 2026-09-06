return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- master ブランチは凍結済み。Neovim 0.12 は main ブランチのみ対応
	lazy = false, -- main ブランチは遅延読み込み非対応
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		-- vimwiki ファイルも markdown パーサーで扱う（image.nvim 連携用）
		vim.treesitter.language.register("markdown", "vimwiki")

		local parsers = {
			"tsx",
			"typescript",
			"javascript",
			"toml",
			"fish",
			"json",
			"yaml",
			"css",
			"html",
			"svelte",
			"lua",
			"regex",
			"markdown",
			"markdown_inline",
			"bash",
			"latex",
			"python",
			"haskell",
		}

		-- 未インストールのパーサーだけ非同期で導入する（起動クリティカルパスから外す）
		vim.schedule(function()
			require("nvim-treesitter").install(parsers)
		end)

		-- main ブランチには highlight / indent モジュールが無いので自前で有効化する
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				if pcall(vim.treesitter.start, buf) then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
