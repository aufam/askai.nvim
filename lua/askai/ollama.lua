local config = require("askai.config")
local ui = require("askai.ui")

---@type AskAIProvider
local M = {}

---@param sel Selection
---@param user_input string
function M.request(sel, user_input)
	local api_key = os.getenv("OLLAMA_API_KEY") or ""
	local url = config.options.ollama.url
	local model = config.options.ollama.model
	if not model then
		vim.cmd('echo "Ollama model not set in config"')
		return
	end

	local prompt = config.options.prompt .. "\n" .. user_input .. "\n\n" .. sel.text
	local body = vim.fn.json_encode({
		prompt = prompt,
		model = model,
		stream = false,
	})

	local cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		url,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
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
				vim.notify("Failed to parse Ollama response", vim.log.levels.ERROR)
				return
			end

			local text = decoded.response
			local error = decoded.error

			if text then
				ui.open(text, sel)
			elseif error then
				vim.notify("Gemini response error: " .. error, vim.log.levels.ERROR)
			end
		end,
	})
end

return M
