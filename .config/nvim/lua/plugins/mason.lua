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
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- サーバ個別設定
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
					-- "--header-insertion=never", -- 補完で勝手に #include を挿入しない
					"--offset-encoding=utf-16",
				},
			})

			require("mason-lspconfig").setup({
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
				automatic_enable = { exclude = { "hls" } }, -- haskellを除外
			})
		end,
	},
}
