return {
	"3rd/image.nvim",
	-- 画像を描画する filetype でのみロード（integrations.markdown.filetypes と揃える）
	ft = { "markdown", "vimwiki" },
	dependencies = {
		-- luarocks経由でmagickパッケージをインストールするために必要になる場合があります
		-- お使いの環境に合わせて追加してください
	},
	opts = {
		backend = "kitty", -- WezTermのプロトコルを明示的に指定
		max_width = 100,
		max_height = 120,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true, -- ウィンドウが重なった時に画像を隠す

		-- 各種ファイルタイプとの連携
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki" },
			},
		},
	},
}
