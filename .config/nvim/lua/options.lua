local options = {
	encoding = "utf-8",
	fileencoding = "utf-8",
	number = true,
	wrap = false,
	hlsearch = true,
	clipboard = "unnamedplus",
	ambiwidth = "single",
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd("colorscheme onedark_dark")
