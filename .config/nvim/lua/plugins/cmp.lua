-- 補完: blink.cmp（nvim-cmp + cmp-* + vim-vsnip + lspkind から移行）
-- Rust 製ファジーマッチャ内蔵の一体型。スニペット・アイコン・シグネチャも本体で完結。
-- version = "1.*" はリリースのプリビルドバイナリを使うので Rust ツールチェーン不要。
return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"rafamadriz/friendly-snippets", -- スニペット集（vim-vsnip の置き換え相当）
			"fang2hou/blink-copilot", -- Copilot を補完ソースに
		},
		opts = {
			keymap = {
				preset = "default", -- C-space:表示 / C-y:確定 / C-e:非表示 / C-n,C-p:選択 / C-b,C-f:doc スクロール / C-k:シグネチャ
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-l>"] = { "show", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true }, -- 旧 experimental.ghost_text 相当
			},
			signature = { enabled = true },
			sources = {
				-- Copilot は「起動中のときだけ」補完ソースに入れる。
				-- 既定では copilot.lua をロードしない（:Copilot enable でロード＆有効化）ため、
				-- package.loaded を見て未ロードなら触らない（lazy の require フックを踏まない）。
				default = function()
					local srcs = { "lsp", "path", "snippets", "buffer", "lazydev" }
					local cc = package.loaded["copilot.client"]
					if cc and cc.get and cc.get() ~= nil then
						srcs[#srcs + 1] = "copilot"
					end
					return srcs
				end,
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- 旧 group_index = 0 相当（LuaLS より優先）
					},
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
					},
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
}
