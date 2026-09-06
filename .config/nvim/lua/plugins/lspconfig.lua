return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		vim.diagnostic.config({
			underline = true,
			severity_sort = true,
			update_in_insert = false,
			virtual_text = { spacing = 2, prefix = "●" },
			virtual_lines = { current_line = true }, -- カーソル行だけ複数行で詳細表示
			float = { border = "rounded", source = true },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			},
		})

		local function gmap(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
		end
		gmap("<C-e>", vim.diagnostic.open_float, "診断: フロート表示")
		gmap("ge", vim.diagnostic.open_float, "診断: フロート表示")
		gmap("[p", function()
			vim.diagnostic.jump({ count = -1 })
		end, "診断: 前へ")
		gmap("[n", function()
			vim.diagnostic.jump({ count = 1 })
		end, "診断: 次へ")

		-- UI トグル
		gmap("<leader>uh", function()
			local on = not vim.lsp.inlay_hint.is_enabled()
			vim.lsp.inlay_hint.enable(on)
			vim.notify("inlay hints: " .. (on and "on" or "off"))
		end, "トグル: inlay hints")
		gmap("<leader>ul", function()
			local cfg = vim.diagnostic.config()
			local on = not (cfg.virtual_lines and cfg.virtual_lines ~= false)
			vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false })
			vim.notify("diagnostic virtual_lines: " .. (on and "on" or "off"))
		end, "トグル: 診断の複数行表示")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
			callback = function(ev)
				local function map(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end
				map("<C-h>", vim.lsp.buf.hover, "LSP: ホバー")
				map("<C-k>", vim.lsp.buf.signature_help, "LSP: シグネチャヘルプ")
				map("gd", vim.lsp.buf.definition, "LSP: 定義へ")
				map("gD", vim.lsp.buf.declaration, "LSP: 宣言へ")
				map("gr", vim.lsp.buf.references, "LSP: 参照一覧")
				map("gi", vim.lsp.buf.implementation, "LSP: 実装へ")
				map("gN", vim.lsp.buf.rename, "LSP: リネーム")
			end,
		})
	end,
}
