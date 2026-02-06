local M = {}

local title = " AI Response  [q] quit  [y] yank  [r] replace "

local function compute_size(lines)
	local max_width = vim.fn.strdisplaywidth(title)
	for _, l in ipairs(lines) do
		max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
	end

	local width = math.min(max_width + 2, math.floor(vim.o.columns * 0.6))
	local height = math.min(#lines, math.floor(vim.o.lines * 0.5))

	return width, height
end

---@param response string
---@param sel Selection
function M.open(response, sel)
	local lines = vim.split(response, "\n", { plain = true })

	local lang = lines[1]:match("^```(%w+)")
	if lang and lines[#lines] == "```" then
		table.remove(lines, 1)
		table.remove(lines, #lines)
	else
		lang = "markdown"
	end

	local parent_buffer_id = vim.api.nvim_get_current_buf()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width, height = compute_size(lines)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = { { title, "AskAITitle" } },
		title_pos = "center",
	})

	vim.api.nvim_set_hl(0, "AskAITitle", { bold = true })
	vim.bo[buf].filetype = lang
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false

	-- quit
	vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = buf, silent = true })

	-- yank
	vim.keymap.set("n", "y", function()
		vim.fn.setreg("+", table.concat(lines, "\n"))
		vim.notify("AI response yanked", vim.log.levels.INFO)
	end, { buffer = buf })

	-- replace
	vim.keymap.set("n", "r", function()
		vim.api.nvim_buf_set_lines(parent_buffer_id, sel.range[1] - 1, sel.range[2], false, lines)
		vim.cmd("bd!")
	end, { buffer = buf })
end

return M
