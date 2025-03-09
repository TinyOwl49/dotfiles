return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local status, ts = pcall(require, "nvim-treesitter.configs")
		if not status then
			return
		end

		ts.setup({
			highlight = {
				enable = true,
				disable = {},
			},
			indent = {
				enable = true,
				disable = {},
			},
			ensure_installed = {
				"tsx",
				"toml",
				"fish",
				"json",
				"yaml",
				"css",
				"html",
				"svelte",
				"lua",
				"regex",
				"markdown",
				"markdown_inline",
				"bash",
				"latex",
			},
			-- autotag = {
			-- 	enable = true,
			-- filetypes = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
			-- },
		})

		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
	end,
}
