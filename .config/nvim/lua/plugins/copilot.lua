-- Github Coplit setup
-- Copilot is an AI pair programmer that helps you write code faster.

-- This plugin requires the following setup:
-- - Python 3.9 or later
-- - Node.js 12.0 or later
-- - Rust 1.45 or later
-- - Go 1.16 or later
-- - CMake 3.14 or later
-- - Make 4.0 or later
-- - Clang 11.0 or later
-- - LLVM 11.0 or later
-- - Docker 20.10 or later
-- - Docker Compose 1.27 or later
-- - AWS CLI 2.0 or later
-- - Git 2.27 or later
-- - GitHub CLI 2.0 or later
-- - cURL 7.64 or later
-- - jq 1.6 or later
-- - unzip 6.0 or later
-- - tar 1.30 or later

-- The plugin is disabled by default, to enable it, set `lazy` to `false` in the plugin list.

-- More info:

return {
	{
		-- copilot.vim(VimL) から copilot.lua(Lua) へ移行。
		-- 既定ではロードしない。`:Copilot enable`（または CopilotChat 起動）で初めてロードされる。
		-- 補完は blink-copilot 経由で blink.cmp のメニューに出すので suggestion/panel は無効化。
		"zbirenbaum/copilot.lua",
		cmd = "Copilot", -- :Copilot ... を叩いたときだけロード（plugin/copilot.lua が実コマンドを定義）
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = { ["*"] = true }, -- どこでも attach 可（blink 経由で使うため）
		},
		config = function(_, opts)
			require("copilot").setup(opts) -- init.lua が内部で command.enable() を呼ぶ
			-- 既定はオフ。ロード直後にいったん無効化し、ユーザーが :Copilot enable した時だけ有効化する。
			-- （lazy は :Copilot <sub> を stub 経由でロード後に再実行するので enable も正しく効く）
			require("copilot.command").disable()
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		-- チャットを実際に呼んだときだけロード（tiktoken 等で ~30ms かかるため）
		cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle", "CopilotChatReset" },
		keys = {
			{ "<leader>cc", "<cmd>CopilotChatOpen<CR>", desc = "Copilot Chat" },
			{ "<leader>ce", desc = "Copilot: Explain",  mode = { "n", "x" } },
			{ "<leader>cr", desc = "Copilot: Review",   mode = { "n", "x" } },
			{ "<leader>cf", desc = "Copilot: Fix",      mode = { "n", "x" } },
			{ "<leader>co", desc = "Copilot: Optimize", mode = { "n", "x" } },
			{ "<leader>cd", desc = "Copilot: Docs",     mode = { "n", "x" } },
			{ "<leader>cD", desc = "Copilot: FixDiagnostic" },
			{ "<leader>ct", desc = "Copilot: Tests",    mode = { "n", "x" } },
			{ "<leader>cg", desc = "Copilot: Commit" },
			{ "<leader>cs", desc = "Copilot: CommitStaged" },
		},
		opts = {
			-- See Configuration section for options
		},
		config = function()
			require("CopilotChat").setup({
				show_help = false,
				suggestion = { enabled = false },
				panel = { enabled = false },
				prompts = {
					Explain = {
						prompt = "/COPILOT_EXPLAIN コードを日本語で説明してください",
						mapping = "<leader>ce",
						description = "コードの説明をお願いする",
					},
					Review = {
						prompt = "/COPILOT_REVIEW コードを日本語でレビューしてください。",
						mapping = "<leader>cr",
						description = "コードのレビューをお願いする",
					},
					Fix = {
						prompt = "/COPILOT_FIX このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします。",
						mapping = "<leader>cf",
						description = "コードの修正をお願いする",
					},
					Optimize = {
						prompt = "/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします。",
						mapping = "<leader>co",
						description = "コードの最適化をお願いする",
					},
					Docs = {
						prompt = "/COPILOT_GENERATE 選択したコードに関するドキュメントコメントを日本語で生成してください。",
						mapping = "<leader>cd",
						description = "コードのドキュメント作成をお願いする",
					},
					Tests = {
						prompt = "/COPILOT_TESTS 選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします。",
						mapping = "<leader>ct",
						description = "テストコード作成をお願いする",
					},
					FixDiagnostic = {
						prompt = "コードの診断結果に従って問題を修正してください。修正内容の説明は日本語でお願いします。",
						mapping = "<leader>cD", -- Docs と重複していたため変更
						description = "診断結果に従ってコードの修正をお願いする",
						selection = require("CopilotChat.select").diagnostics,
					},
					Commit = {
						prompt = "実装差分に対するコミットメッセージを日本語で記述してください。",
						mapping = "<leader>cg",
						description = "コミットメッセージの作成をお願いする",
						selection = require("CopilotChat.select").gitdiff,
					},
					CommitStaged = {
						prompt = "ステージ済みの変更に対するコミットメッセージを日本語で記述してください。",
						mapping = "<leader>cs",
						description = "ステージ済みのコミットメッセージの作成をお願いする",
						selection = function(source)
							return require("CopilotChat.select").gitdiff(source, true)
						end,
					},
				},
			})

			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<leader>cc", "<ESC>:CopilotChatOpen<CR>", opts)
		end,
		-- See Commands section for default commands if you want to lazy load on them
	},
}
