-- プラグインの多重読み込みを防止
if vim.g.loaded_numberformat then
	return
end
vim.g.loaded_numberformat = 1

local M = {}

--- 有効数字 n 桁にフォーマット (指数表記を使用しない)
-- @param num_str string: 数値文字列
-- @param n integer: 有効数字の桁数
-- @return string: フォーマットされた数値文字列
function M.format_significant(num_str, n)
	local num = tonumber(num_str)
	if not num then
		return num_str
	end

	-- 桁数は最低1桁
	n = math.max(1, math.floor(n))

	if num == 0 then
		if n == 1 then
			return "0"
		end
		-- n=2 -> 0.0, n=3 -> 0.00
		return "0." .. string.rep("0", n - 1)
	end

	-- 10を底とする対数で、数値の「桁」（大きさ）を取得
	-- 例: 123.45 -> 2.09... -> floor = 2 (10^2 の桁)
	-- 例: 0.0123 -> -1.91... -> floor = -2 (10^-2 の桁)
	local magnitude = math.floor(math.log10(math.abs(num)))

	-- string.format("%.*f") に渡す「小数点以下の桁数」を計算
	-- (有効数字の桁数 - 1) - (基準となる桁)
	local precision = (n - 1) - magnitude

	if precision < 0 then
		-- 1の位より左側で四捨五入する場合 (例: 123.45 (n=2) -> 120)
		local factor = 10 ^ -precision
		local rounded
		if num >= 0 then
			-- (num / factor) + 0.5 の floor で四捨五入
			rounded = math.floor((num / factor) + 0.5) * factor
		else
			-- 負の数の場合
			rounded = math.ceil((num / factor) - 0.5) * factor
		end
		-- 整数 (小数点以下0桁) としてフォーマット
		return string.format("%.0f", rounded)
	else
		-- 小数点以下で四捨五入する場合 (例: 0.0123 (n=2) -> 0.012)
		return string.format("%.*f", precision, num)
	end
end

--- 小数点以下 n 桁にフォーマット
-- @param num_str string: 数値文字列
-- @param n integer: 小数点以下の桁数
-- @return string: フォーマットされた数値文字列
function M.format_decimal(num_str, n)
	local num = tonumber(num_str)
	if not num then
		return num_str
	end
	-- 桁数は0以上
	n = math.max(0, math.floor(n))
	return string.format("%.*f", n, num)
end

--- :NumberFormat コマンドの定義
vim.api.nvim_create_user_command("NumberFormat", function(opts)
	-- 1. 引数の解析
	local args = opts.fargs
	if #args ~= 2 then
		vim.notify("使用法: :NumberFormat <-d|-s> <桁数>", vim.log.levels.WARN, { title = "NumberFormat" })
		return
	end

	local mode = args[1]
	local n = tonumber(args[2])

	if (mode ~= "-d" and mode ~= "-s") or not n then
		vim.notify("引数が不正です。例: -d 3 または -s 2", vim.log.levels.WARN, { title = "NumberFormat" })
		return
	end

	local format_func
	if mode == "-d" then
		format_func = function(num_str)
			return M.format_decimal(num_str, n)
		end
	else
		format_func = function(num_str)
			return M.format_significant(num_str, n)
		end
	end

	-- 2. Visual モードの範囲を取得
	-- コマンド実行時にはノーマルモードに戻っているため、直前のVisualモード情報を取得
	local vmode = vim.fn.visualmode(1)
	if vmode == "" then
		-- :NumberFormat が Visual モード以外から実行された場合
		vim.notify(
			"Visualモードで範囲を選択してください。",
			vim.log.levels.WARN,
			{ title = "NumberFormat" }
		)
		return
	end

	-- Visual 範囲の開始位置 ('<) と終了位置 ('>) を取得
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3] -- バイト単位の列
	local end_line = end_pos[2]
	local end_col = end_pos[3] -- バイト単位の列

	-- 選択方向（下から上など）によって位置が逆転している場合を正規化
	if start_line > end_line or (start_line == end_line and start_col > end_col) then
		start_line, end_line = end_line, start_line
		start_col, end_col = end_col, start_col
	end

	-- ブロックモード (<C-v>) で右から左に選択した場合、列を正規化
	if vmode == "\22" and start_col > end_col then
		start_col, end_col = end_col, start_col
	end

	-- 'selection' オプション (exclusive/inclusive) を考慮
	local selection_inclusive = vim.o.selection == "inclusive"
	local end_col_v = end_col

	-- 'v' (文字単位) かつ 'exclusive' (デフォルト) の場合、
	-- end_col は選択範囲の *直後* を指すため、判定用に -1 する
	if not selection_inclusive and vmode == "v" then
		end_col_v = end_col - 1
	end

	-- 3. 対象行のテキストを取得して処理
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local new_lines = {}

	-- 正規表現パターン:
	-- (
	--   [-+]? (
	--     [0-9]+ (\. [0-9]*)?  -- "123" or "123." or "123.45"
	--     | \. [0-9]+          -- ".45"
	--   )
	-- ) (
	--   [eE] [-+]? [0-9]+    -- "e10", "E-2" (Optional)
	-- )?
	-- このパターンにより "e10" の "10" が単独でマッチすることを防ぎます
	local pattern = "([-+]?([0-9]+(%.[0-9]*)?|%.[0-9]+))([eE][-+]?[0-9]+)?"

	for i, line in ipairs(lines) do
		local current_line_num = start_line + i - 1
		local new_line = ""
		local last_index = 1

		-- string.find() をループで回して、マッチ位置 (s, e) を取得
		while true do
			-- s, e: マッチ全体のバイトインデックス
			local s, e, number_part, _, _, exponent_part = line:find(pattern, last_index)

			if not s then
				-- マッチしなくなったら残りの文字列を追加して終了
				new_line = new_line .. line:sub(last_index)
				break
			end

			-- マッチ前の部分をそのまま追加
			new_line = new_line .. line:sub(last_index, s - 1)

			-- マッチした数値 (s, e) が Visual 範囲とオーバーラップしているか判定
			local in_visual_range = false

			if vmode == "V" then -- 行選択 ('V')
				in_visual_range = true
			elseif vmode == "v" then -- 文字選択 ('v')
				if current_line_num == start_line and current_line_num == end_line then
					-- 単一行: [start_col, end_col_v] と [s, e] がオーバーラップ
					if e >= start_col and s <= end_col_v then
						in_visual_range = true
					end
				elseif current_line_num == start_line then
					-- 複数行 (開始行): [start_col, EOL]
					if e >= start_col then
						in_visual_range = true
					end
				elseif current_line_num == end_line then
					-- 複数行 (終了行): [1, end_col_v]
					if s <= end_col_v then
						in_visual_range = true
					end
				else -- 中間行
					in_visual_range = true
				end
			elseif vmode == "\22" then -- ブロック選択 (<C-v>)
				-- ブロックモードは常に inclusive な動作
				-- [start_col, end_col] と [s, e] がオーバーラップ
				if e >= start_col and s <= end_col then
					in_visual_range = true
				end
			end

			local original_match = line:sub(s, e)

			if in_visual_range then
				-- 範囲内ならフォーマット
				local formatted = format_func(number_part)
				if exponent_part then
					new_line = new_line .. formatted .. exponent_part
				else
					new_line = new_line .. formatted
				end
			else
				-- 範囲外ならそのまま
				new_line = new_line .. original_match
			end

			last_index = e + 1
		end
		table.insert(new_lines, new_line)
	end

	-- 4. バッファの更新
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end, {
	nargs = "+", -- 引数 (例: "-d 3") を必須にする
	range = 0, -- Visual モードでのみ使用可能
	desc = "Visual範囲の数値をフォーマット (-d N または -s N)",
})
