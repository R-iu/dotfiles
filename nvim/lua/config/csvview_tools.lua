local M = {}

local Cmdline = require("csvview.cmdline")

local filter_cmdline = Cmdline:new({
	{ name = "column" },
	{ name = "col" },
	{ name = "value" },
	{ name = "pattern" },
	{ name = "equals" },
	{ name = "ignorecase", candidates = { "true", "false" } },
})

local rank_cmdline = Cmdline:new({
	{ name = "column" },
	{ name = "col" },
	{ name = "order", candidates = { "asc", "desc" } },
	{ name = "limit" },
})

local sort_cmdline = Cmdline:new({
	{ name = "column" },
	{ name = "col" },
	{ name = "order", candidates = { "asc", "desc" } },
})

local function unescape_arg(value)
	return (value:gsub("\\t", "\t"):gsub("\\ ", " "))
end

local function parse_args(args)
	local parsed = {}
	local start = 1

	while start <= #args do
		local next_start = args:find("%s+[%w_%-]+=", start + 1)
		local item_text = args:sub(start, next_start and next_start - 1 or #args):match("^%s*(.-)%s*$")
		local key, value = item_text:match("^([^=]+)=(.*)$")
		if key and value then
			parsed[key] = unescape_arg(value)
		end
		if not next_start then
			break
		end
		start = args:find("[%w_%-]+=", next_start)
	end

	return parsed
end

local function split_record(line, delimiter, quote_char)
	local fields = {}
	local field = {}
	local pos = 1
	local delimiter_len = #delimiter
	local in_quote = false

	while pos <= #line do
		local char = line:sub(pos, pos)
		if char == quote_char then
			if in_quote and line:sub(pos + 1, pos + 1) == quote_char then
				table.insert(field, quote_char)
				pos = pos + 1
			else
				in_quote = not in_quote
			end
		elseif not in_quote and line:sub(pos, pos + delimiter_len - 1) == delimiter then
			table.insert(fields, table.concat(field))
			field = {}
			pos = pos + delimiter_len - 1
		else
			table.insert(field, char)
		end
		pos = pos + 1
	end

	table.insert(fields, table.concat(field))
	return fields
end

local function quote_field(field, delimiter, quote_char)
	field = tostring(field or "")
	if field:find(delimiter, 1, true) or field:find(quote_char, 1, true) or field:find("\n", 1, true) then
		return quote_char .. field:gsub(quote_char, quote_char .. quote_char) .. quote_char
	end
	return field
end

local function join_record(fields, delimiter, quote_char)
	local out = {}
	for index, field in ipairs(fields) do
		out[index] = quote_field(field, delimiter, quote_char)
	end
	return table.concat(out, delimiter)
end

local function get_csv_context()
	local bufnr = vim.api.nvim_get_current_buf()
	local info = vim.b[bufnr].csvview_info or {}
	local delimiter = info.delimiter and info.delimiter.text or ","
	local quote_char = info.quote_char and info.quote_char.text or '"'
	local header_lnum = info.header and info.header.lnum or 1
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return bufnr, lines, delimiter, quote_char, header_lnum
end

local function resolve_column(column, header)
	if not column or column == "" then
		return nil
	end

	local numeric = tonumber(column)
	if numeric then
		return numeric
	end

	for index, name in ipairs(header) do
		if name == column then
			return index
		end
	end
	return nil
end

local function open_result_buffer(name, lines)
	vim.cmd("vnew")
	local bufnr = vim.api.nvim_get_current_buf()
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "wipe"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = "csv"
	vim.api.nvim_buf_set_name(bufnr, string.format("%s://%d", name, vim.uv.hrtime()))
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].modified = false
	pcall(vim.cmd, "CsvViewEnable")
end

local function to_number(value)
	if not value then
		return nil
	end
	return tonumber((value:gsub("[^%d%+%-%.]", "")))
end

local function sort_rows(rows, column, descending)
	table.sort(rows, function(left, right)
		local left_value = left.fields[column] or ""
		local right_value = right.fields[column] or ""
		local left_number = to_number(left_value)
		local right_number = to_number(right_value)

		if left_number and right_number then
			if left_number == right_number then
				return left.lnum < right.lnum
			end
			if descending then
				return left_number > right_number
			end
			return left_number < right_number
		end

		if left_value == right_value then
			return left.lnum < right.lnum
		end
		if descending then
			return left_value > right_value
		end
		return left_value < right_value
	end)
end

local function should_match(value, args)
	value = value or ""
	local haystack = args.ignorecase == "false" and value or value:lower()

	if args.equals then
		local needle = args.ignorecase == "false" and args.equals or args.equals:lower()
		return haystack == needle
	end

	if args.pattern then
		local pattern = args.ignorecase == "false" and args.pattern or args.pattern:lower()
		return haystack:find(pattern) ~= nil
	end

	if args.value then
		local needle = args.ignorecase == "false" and args.value or args.value:lower()
		return haystack:find(needle, 1, true) ~= nil
	end

	return false
end

local function collect_records(lines, delimiter, quote_char, header_lnum)
	local header = split_record(lines[header_lnum] or "", delimiter, quote_char)
	local rows = {}
	for lnum = header_lnum + 1, #lines do
		if lines[lnum] ~= "" then
			table.insert(rows, {
				lnum = lnum,
				fields = split_record(lines[lnum], delimiter, quote_char),
			})
		end
	end
	return header, rows
end

function M.filter(args_line)
	local args = parse_args(args_line)
	if not (args.value or args.pattern or args.equals) then
		vim.notify("CsvViewFilter requires value=, pattern=, or equals=", vim.log.levels.ERROR)
		return
	end

	local _, lines, delimiter, quote_char, header_lnum = get_csv_context()
	local header, rows = collect_records(lines, delimiter, quote_char, header_lnum)
	local column = resolve_column(args.column or args.col, header)
	if not column then
		vim.notify("CsvViewFilter requires column=<name-or-number>", vim.log.levels.ERROR)
		return
	end

	local result = { join_record(header, delimiter, quote_char) }
	for _, row in ipairs(rows) do
		if should_match(row.fields[column], args) then
			table.insert(result, join_record(row.fields, delimiter, quote_char))
		end
	end

	open_result_buffer("csvview-filter", result)
	vim.notify(string.format("CsvViewFilter: %d rows", #result - 1))
end

function M.rank(args_line)
	local args = parse_args(args_line)
	local _, lines, delimiter, quote_char, header_lnum = get_csv_context()
	local header, rows = collect_records(lines, delimiter, quote_char, header_lnum)
	local column = resolve_column(args.column or args.col, header)
	if not column then
		vim.notify("CsvViewRank requires column=<name-or-number>", vim.log.levels.ERROR)
		return
	end

	local descending = args.order ~= "asc"
	sort_rows(rows, column, descending)

	local limit = tonumber(args.limit) or #rows
	local result = { join_record(vim.list_extend({ "Rank" }, vim.deepcopy(header)), delimiter, quote_char) }
	for index, row in ipairs(rows) do
		if index > limit then
			break
		end
		local fields = vim.list_extend({ tostring(index) }, vim.deepcopy(row.fields))
		table.insert(result, join_record(fields, delimiter, quote_char))
	end

	open_result_buffer("csvview-rank", result)
	vim.notify(string.format("CsvViewRank: %d rows", #result - 1))
end

function M.sort(args_line)
	local args = parse_args(args_line)
	local _, lines, delimiter, quote_char, header_lnum = get_csv_context()
	local header, rows = collect_records(lines, delimiter, quote_char, header_lnum)
	local column = resolve_column(args.column or args.col, header)
	if not column then
		vim.notify("CsvViewSort requires column=<name-or-number>", vim.log.levels.ERROR)
		return
	end

	local descending = args.order == "desc"
	sort_rows(rows, column, descending)

	local result = { join_record(header, delimiter, quote_char) }
	for _, row in ipairs(rows) do
		table.insert(result, join_record(row.fields, delimiter, quote_char))
	end

	open_result_buffer("csvview-sort", result)
	vim.notify(string.format("CsvViewSort: %d rows", #result - 1))
end

function M.setup()
	vim.api.nvim_create_user_command("CsvViewFilter", function(opts)
		M.filter(opts.args)
	end, {
		desc = "Filter the current CSV into a scratch buffer",
		nargs = "+",
		complete = function(arg_lead, cmd_line, cursor_pos)
			return filter_cmdline:complete(arg_lead, cmd_line, cursor_pos)
		end,
	})

	vim.api.nvim_create_user_command("CsvViewRank", function(opts)
		M.rank(opts.args)
	end, {
		desc = "Rank the current CSV by a column into a scratch buffer",
		nargs = "+",
		complete = function(arg_lead, cmd_line, cursor_pos)
			return rank_cmdline:complete(arg_lead, cmd_line, cursor_pos)
		end,
	})

	vim.api.nvim_create_user_command("CsvViewSort", function(opts)
		M.sort(opts.args)
	end, {
		desc = "Sort the current CSV by a column into a scratch buffer",
		nargs = "+",
		complete = function(arg_lead, cmd_line, cursor_pos)
			return sort_cmdline:complete(arg_lead, cmd_line, cursor_pos)
		end,
	})
end

return M
