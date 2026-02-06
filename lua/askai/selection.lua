local M = {}

---@class Range
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer

---@class Selection
---@field text string
---@field range Range

---@param range integer
---@return Selection?
function M.get_visual_selection_with_range(range)
	local bufnr = 0

	if range == 0 then
		local rowcol = vim.api.nvim_win_get_cursor(bufnr)
		return {
			text = "",
			range = { start_row = rowcol[1], start_col = rowcol[2], end_row = rowcol[1], end_col = rowcol[2] },
		}
	end

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
	if ce ~= vim.v.maxcol then
		ce = ce + 1
		lines[#lines] = string.sub(lines[#lines], 1, ce)
	else
		ce = #lines[#lines]
	end
	lines[1] = string.sub(lines[1], cs + 1)

	return {
		text = table.concat(lines, "\n"),
		range = { start_row = ls - 1, start_col = cs, end_row = le - 1, end_col = ce },
	}
end

return M
