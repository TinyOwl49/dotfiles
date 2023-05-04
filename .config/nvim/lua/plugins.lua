require("packer").startup(function()
	use("wbthomason/packer.nvim")
	use("neovim/nvim-lspconfig")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	use("vim-airline/vim-airline") -- ステータスバーをかっこよくする
	use("vim-airline/vim-airline-themes") -- airlineのcolorscheme
	use("tpope/vim-fugitive")      -- gitの操作
	use("airblade/vim-gitgutter")  --git差分の表示
	-- use 'obaland/vfiler.vim'
	-- use 'obaland/vfiler-fzf'
	-- use 'ibhagwan/fzf-lua'
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		requires = { { "nvim-lua/plenary.nvim" } },
	}) -- ファイル検索
	use({
		"folke/noice.nvim",
		requires = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	}) -- 通知を表示
	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
	}) -- lua製のターミナル

	-- defx (file explorer)
	use("Shougo/defx.nvim")
	use("kristijanhusak/defx-icons")
	use("ryanoasis/vim-devicons")
	use("kristijanhusak/defx-git")
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
	})

	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/vim-vsnip")
	use("onsails/lspkind.nvim")

	use("mfussenegger/nvim-dap")
	use("rcarriga/nvim-dap-ui")
	use("https://github.com/mfussenegger/nvim-dap-python")

	-- ### colorscheme
	use("navarasu/onedark.nvim")
	use("olimorris/onedarkpro.nvim")
	use("jonathanfilip/vim-lucius")
	use("EdenEast/nightfox.nvim")
	use("cocopon/iceberg.vim")
	use("folke/tokyonight.nvim")

	use("machakann/vim-highlightedyank") -- yankを光らせる
	use("andweeb/presence.nvim")  -- discord rich presence
	use("tpope/vim-commentary")   -- コメントアウトを便利にする
	use("tversteeg/registers.nvim") -- レギストリを表示
	use("machakann/vim-sandwich") -- テキストをサンドウィッチする
	use("vim-jp/vimdoc-ja")       -- ドキュメントを日本語に
	use("folke/neodev.nvim")      -- luaでneovim設定を書くためのプラグイン
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	})                                  -- 括弧を閉じてくれる
	use("lukas-reineke/indent-blankline.nvim") -- インデントをわかりやすく表示
	use("skanehira/translate.vim")      -- 英語を日本語に翻訳
	use({
		"vim-denops/denops.vim",
		requires = { { "vim-denops/denops-helloworld.vim" } },
	}) -- denops
	use({
		"narutoxy/silicon.lua",
		requires = { "nvim-lua/plenary.nvim" },
	})

	-- ### language
	use({
		"numirias/semshi",
		-- opt = true, ft = { 'python' }
	})
	use({
		"zah/nim.vim",
		-- opt = true, ft = { 'nim' }
		-- なぜかftが使えない
	})
	use({
		"rust-lang/rust.vim",
	})
	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})
	use({
		"windwp/nvim-ts-autotag",
		-- ft = {
		-- 	"html",
		-- 	"javascript",
		-- 	"typescript",
		-- 	"javascriptreact",
		-- 	"typescriptreact",
		-- 	"svelte",
		-- 	"vue",
		-- 	"tsx",
		-- 	"jsx",
		-- 	"rescript",
		-- },
	})
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})

	use({
		"evanleck/vim-svelte",
		requires = {
			"othree/html5.vim",
			"pangloss/vim-javascript",
		},
		config = function()
			vim.g.svelte_preprocessors = { "typescript" }
		end,
	})
end)
