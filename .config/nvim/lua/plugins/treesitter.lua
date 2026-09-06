return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		vim.treesitter.language.register("markdown", "vimwiki")

		local parsers = {
			"tsx",
			"typescript",
			"javascript",
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
			"python",
			"haskell",
		}

		vim.schedule(function()
			require("nvim-treesitter").install(parsers)
		end)

		-- highlight / indent
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local buf = args.buf
				if pcall(vim.treesitter.start, buf) then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
