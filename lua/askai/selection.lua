local M = {}

---@class Range
---@field [1] integer start line
---@field [2] integer end line

---@class Selection
---@field text string
---@field range Range

---@return Selection?
function M.get_visual_selection_with_range()
	local bufnr = 0

	-- Marks '< and '>
	local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
	local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")

	local ls, cs = start_pos[1], start_pos[2]
	local le, ce = end_pos[1], end_pos[2]

	if ls == 0 or le == 0 then
		vim.notify("No visual selection found", vim.log.levels.ERROR)
		return nil
	end

	-- Convert to 0-based for API calls
	local start_row = ls - 1
	local end_row = le - 1

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
	if #lines == 0 then
		vim.notify("No visual selection found", vim.log.levels.ERROR)
		return nil
	end

	-- Trim columns (cs/ce are 0-based byte indices)
	lines[1] = string.sub(lines[1], cs + 1)
	lines[#lines] = string.sub(lines[#lines], 1, ce + 1)

	return {
		text = table.concat(lines, "\n"),
		range = { ls, le }, -- keep 1-based rows for user commands
	}
end

return M
