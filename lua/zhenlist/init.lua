local M = {}

M.config = {
	window = {
		border = "rounded",
		title = "zhenlist",
		title_pos = "left",
	},
	insert_on_item_add = true,
	insert_with_a = false,
	keymap = {
		add_item = "o",
	},
	disable_omni_completion = true,
}

local autocmd = vim.api.nvim_create_autocmd
local keymap_opts = { buffer = true, silent = true }
local keymap = vim.keymap.set
local checklist_bufnr = nil
local checklist_winid = nil
local script_path = debug.getinfo(1, "S").source:sub(2)
local plugin_dir = script_path:match("(.*[/\\])")
local file_path = plugin_dir .. "zhenlist.md"

function M.toggle_zhenlist()
	if checklist_winid and vim.api.nvim_win_is_valid(checklist_winid) then
		vim.api.nvim_win_close(checklist_winid, true)
		if checklist_bufnr and vim.api.nvim_buf_is_valid(checklist_bufnr) then
			vim.api.nvim_buf_delete(checklist_bufnr, { force = true })
		end
		checklist_winid = nil
		return
	end

	if vim.fn.filereadable(file_path) == 0 then
		vim.fn.writefile({}, file_path)
	end

	checklist_bufnr = vim.fn.bufnr(file_path, true)
	if not vim.api.nvim_buf_is_loaded(checklist_bufnr) then
		vim.api.nvim_buf_call(checklist_bufnr, function()
			vim.cmd("edit " .. vim.fn.fnameescape(file_path))
		end)
	end

	if M.config.disable_omni_completion then
		vim.api.nvim_buf_set_option(checklist_bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	end

	vim.api.nvim_buf_set_option(checklist_bufnr, "filetype", "zhenlist")
	vim.api.nvim_buf_set_option(checklist_bufnr, "syntax", "markdown")

	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.5)
	local row = math.floor((vim.o.lines - height) / 2 - 1)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = M.config.window.border,
		title = M.config.window.title,
		title_pos = M.config.window.title_pos,
	}

	checklist_winid = vim.api.nvim_open_win(checklist_bufnr, true, opts)

	vim.api.nvim_set_option_value("number", false, { scope = "local", win = checklist_winid })
	vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = checklist_winid })
end

function M.add_item(args)
	local msg = args.args or ""
	local new_item
	if M.config.insert_with_a then
		new_item = "- [ ] " .. msg
	else
		new_item = "- [ ]  " .. msg
	end
	local lines = {}

	if checklist_bufnr and vim.api.nvim_buf_is_valid(checklist_bufnr) then
		lines = vim.api.nvim_buf_get_lines(checklist_bufnr, 0, -1, false)
		if #lines == 1 and lines[1] == "" then
			lines[1] = new_item
		else
			table.insert(lines, new_item)
		end
		vim.api.nvim_buf_set_lines(checklist_bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_set_option(checklist_bufnr, "modified", false)
		local new_line_number = vim.api.nvim_buf_line_count(checklist_bufnr)
		if checklist_winid and vim.api.nvim_win_is_valid(checklist_winid) then
			vim.api.nvim_win_set_cursor(checklist_winid, { new_line_number, 6 })
			if M.config.insert_on_item_add then
				vim.cmd("startinsert")
			end
		end
	else
		if vim.fn.filereadable(file_path) == 1 then
			lines = vim.fn.readfile(file_path)
		end
		if #lines == 1 and lines[1] == "" then
			lines[1] = new_item
		else
			table.insert(lines, new_item)
		end
		vim.fn.writefile(lines, file_path)
	end
end

local function toggle_item()
	if
		not (checklist_bufnr and vim.api.nvim_win_is_valid(checklist_winid))
		and checklist_bufnr
		and vim.api.nvim_buf_is_valid(checklist_bufnr)
	then
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(checklist_winid)
	local line_num = cursor[1]

	local prefix, current, suffix, rest = vim.api
		.nvim_buf_get_lines(checklist_bufnr, line_num - 1, line_num, false)[1]
		:match("^(%- %[)%s*([xX]?)%s*(%])(.*)")
	if not prefix then
		return
	end

	local new_marker = (current == "") and "x" or " "
	local new_line = prefix .. new_marker .. suffix .. rest

	vim.api.nvim_buf_set_lines(checklist_bufnr, line_num - 1, line_num, false, { new_line })
	local updated_lines = vim.api.nvim_buf_get_lines(checklist_bufnr, 0, -1, false)
	vim.fn.writefile(updated_lines, file_path)

	vim.cmd("silent! write!")
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	vim.api.nvim_create_user_command("ZhenListToggle", M.toggle_zhenlist, {})
	vim.api.nvim_create_user_command("ZhenListAddItem", M.add_item, { nargs = "*" })
end

local function quit()
	if checklist_winid and vim.api.nvim_win_is_valid(checklist_winid) then
		vim.api.nvim_win_close(checklist_winid, true)
		checklist_winid = nil
		if checklist_bufnr and vim.api.nvim_buf_is_valid(checklist_bufnr) then
			vim.api.nvim_buf_delete(checklist_bufnr, { force = true })
			checklist_bufnr = nil
		end
	else
		vim.cmd("q")
	end
end

autocmd("Filetype", {
	pattern = "zhenlist",
	callback = function()
		keymap("n", "<CR>", function()
			toggle_item()
		end, keymap_opts)
		keymap("n", "q", quit, keymap_opts)
		keymap("n", M.config.keymap.add_item, function()
			M.add_item({ args = "" })
		end, keymap_opts)
	end,
})

return M
