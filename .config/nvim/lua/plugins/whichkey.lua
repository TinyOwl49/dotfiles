-- キーバインドを押しかけると候補をポップアップ表示する（各 keymap の desc を読む）
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern", -- "classic"（下部）/ "helix"（右側）
		delay = 500, -- ポップアップ表示までの待ち時間(既定 200)。
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Copilot" },
			{ "<leader>f", group = "Find (Telescope)" },
			{ "<leader>h", group = "Git hunk / Haskell" },
			{ "<leader>o", group = "Org" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>u", group = "UI toggle" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Which-key: このバッファのキーマップ",
		},
	},
}
