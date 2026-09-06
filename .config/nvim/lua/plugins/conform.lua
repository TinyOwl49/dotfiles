-- フォーマッタ: conform.nvim（none-ls / null-ls から移行）
-- none-ls は「擬似 LSP サーバ」方式で LSP クライアントを1つ増やす。
-- conform は LSP を介さずフォーマッタ CLI を実行し最小 diff を当てるだけ。
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<C-f>",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer / selection",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			nim = { "nimpretty" },
			python = { "black" }, -- 速くしたい場合は { "ruff_format" }
			php = { "php_cs_fixer" },
			rust = { "rustfmt" }, -- rust.vim 削除に伴い conform 側でフォーマット
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		-- 旧 :Format ユーザーコマンドを維持（中身を conform に差し替え）
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			require("conform").format({ async = true, lsp_format = "fallback", range = range })
		end, { range = true })
	end,
}
