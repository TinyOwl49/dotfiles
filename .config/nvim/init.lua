-- LSP ログが肥大化したら起動時に切り詰める（Neovim は自動ローテーションしない）。
-- vim.lsp.log.get_filename() は vim.lsp 一式を読み込む（起動時 ~13ms）ので、パスを直接組む。
do
	local logpath = vim.fn.stdpath("log") .. "/lsp.log"
	local stat = vim.uv.fs_stat(logpath)
	if stat and stat.size > 5 * 1024 * 1024 then
		vim.fn.writefile({}, logpath)
	end
end

require("settings.core.keymaps")
require("settings.core.options")
require("settings.lazy")
require("settings.number-format")
