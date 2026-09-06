-- mason v2（mason-org/*）へ移行。
-- v2 で mason-lspconfig の `setup_handlers` は廃止 → `automatic_enable` が代替。
return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		-- 実ファイルを開いたときにロードして LSP を有効化する
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp", -- capabilities 生成に使う
		},
		config = function()
			-- 全サーバ共通の設定（capabilities は blink.cmp 由来）
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- サーバ個別設定（vim.lsp.config(name, …) は lsp/*.lua より優先される）
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false }, -- 「サードパーティ製ライブラリ」ポップアップ抑制
						codeLens = { enable = true },
						hint = { enable = true, arrayIndex = "Disable" }, -- inlay hints
						diagnostics = { unusedLocalExclude = { "_*" } },
					},
				},
			})
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--completion-style=detailed",
					"--header-insertion=never", -- 補完で勝手に #include を挿入しない
					"--offset-encoding=utf-16",
				},
			})

			require("mason-lspconfig").setup({
				-- 宣言的に管理（新マシンで git clone → 起動だけで揃う）。
				-- 追加・削除したい LSP はここを編集する。
				ensure_installed = {
					"lua_ls",
					"pyright",
					"bashls",
					"clangd",
					"cssls",
					"html",
					"jsonls",
					"ts_ls",
					"svelte",
					"rust_analyzer",
					"texlab",
					"sqlls",
					"nim_langserver",
					"phpactor",
				},
				-- automatic_enable = true が既定: Mason が入れた LSP を vim.lsp.enable で自動有効化。
				-- haskell-language-server は haskell-tools.nvim が管理するため除外。
				automatic_enable = { exclude = { "hls" } },
			})
		end,
	},
}
