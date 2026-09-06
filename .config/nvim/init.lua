-- LSP ログが肥大化したら起動時に切り詰める
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
