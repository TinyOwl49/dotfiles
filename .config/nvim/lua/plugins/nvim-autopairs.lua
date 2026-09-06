-- 括弧を閉じてくれる
return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		disable_filetype = { "TelescopePrompt", "vim" },
	},
}
