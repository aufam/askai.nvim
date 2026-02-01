local config = require("askai.config")
local ui = require("askai.ui")

---@type AskAIProvider
local M = {}

---@param sel Selection
---@param user_input string
function M.request(sel, user_input)
	local anthropic = config.options.anthropic
	if anthropic == nil then
		vim.notify("anthropic is not defined", vim.log.levels.ERROR)
		return
	end

	local api_key = os.getenv("ANTHROPIC_API_KEY")
	if not api_key then
		vim.notify("ANTHROPIC_API_KEY not set", vim.log.levels.ERROR)
		return
	end

	local prompt = config.options.prompt .. "\n" .. user_input .. "\n\n" .. sel.text
	local body = vim.fn.json_encode({
		model = anthropic.model,
		max_token = anthropic.max_tokens,
		messages = {
			{ role = "user", content = prompt },
		},
	})

	local cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		"https://api.anthropic.com/v1/messages",
		"-H",
		"x-api-key: " .. api_key,
		"-H",
		"anthropic-version: " .. anthropic.anthropic_version,
		"-H",
		"Content-Type: application/json",
		"-d",
		body,
	}

	vim.cmd('echo "Thinking..."')

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_exit = function()
			vim.cmd('echo ""')
		end,
		on_stdout = function(_, data)
			if not data or not data[1] then
				return
			end

			local ok, decoded = pcall(vim.fn.json_decode, table.concat(data))
			if not ok then
				vim.notify("Failed to parse Anthropic response", vim.log.levels.ERROR)
				return
			end

			local text = decoded.content and decoded.content[1] and decoded.content[1].text
			local error = decoded.error and decoded.error.message

			if text then
				ui.open(text, sel)
			elseif error then
				vim.notify("Anthropic response error: " .. error, vim.log.levels.ERROR)
			end
		end,
	})
end

return M
