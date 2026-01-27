local config = require("askai.config")
local ui = require("askai.ui")

local M = {}

---@param sel Selection
---@param user_input string
function M.request(sel, user_input)
	local api_key = os.getenv("GEMINI_API_KEY")
	local model = config.options.gemini.model
	local version = config.options.gemini.version
	local prompt = config.options.prompt .. "\n" .. user_input .. "\n\n" .. sel.text

	if not api_key then
		vim.notify("GEMINI_API_KEY not set", vim.log.levels.ERROR)
		return
	end

	local body = vim.fn.json_encode({
		contents = { {
			parts = { {
				text = prompt,
			} },
		} },
	})

	local cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		"https://generativelanguage.googleapis.com/" .. version .. "/models/" .. model .. ":generateContent",
		"-H",
		"Content-Type: application/json",
		"-H",
		"x-goog-api-key: " .. api_key,
		"-d",
		body,
	}

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if not data or not data[1] then
				return
			end

			local ok, decoded = pcall(vim.fn.json_decode, table.concat(data))
			if not ok then
				vim.notify("Failed to parse Gemini response", vim.log.levels.ERROR)
				return
			end

			local text = decoded.candidates
				and decoded.candidates[1]
				and decoded.candidates[1].content
				and decoded.candidates[1].content.parts[1].text

			local error = decoded.error and decoded.error.message

			if text then
				ui.open(text, sel)
			elseif error then
				vim.notify("Gemini response error: " .. error, vim.log.levels.ERROR)
			end
		end,
	})
end

return M
