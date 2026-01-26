local M = {}

local buf, win
local response_lines = {}
local on_replace

local function compute_size(lines)
	local max_width = 0
	for _, l in ipairs(lines) do
		max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
	end

	local width = math.min(max_width + 2, math.floor(vim.o.columns * 0.6))
	local height = math.min(#lines, math.floor(vim.o.lines * 0.5))

	return width, height
end

function M.open(lines, opts)
	opts = opts or {}
	on_replace = opts.on_replace
	response_lines = lines

	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width, height = compute_size(lines)

	win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = { { " AI Response  [q] quit  [y] yank  [r] replace ", "AIPopupTitle" } },
		title_pos = "center",
	})

	vim.api.nvim_set_hl(0, "AIPopupTitle", { bold = true })
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false

	-- quit
	vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = buf, silent = true })

	-- yank
	vim.keymap.set("n", "y", function()
		vim.fn.setreg("+", table.concat(response_lines, "\n"))
		vim.notify("AI response yanked", vim.log.levels.INFO)
	end, { buffer = buf })

	-- replace
	vim.keymap.set("n", "r", function()
		if on_replace then
			on_replace(response_lines)
		end
		vim.cmd("bd!")
	end, { buffer = buf })
end

return M
