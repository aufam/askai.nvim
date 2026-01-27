local config = require("askai.config")
local ui = require("askai.ui")

---@type AskAIProvider
local M = {}

---@param sel Selection
---@param user_input string
function M.request(sel, user_input)
	local openai = config.options.openai
	if openai == nil then
		vim.notify("openai is not defined", vim.log.levels.ERROR)
		return
	end

	local api_key = os.getenv(openai.api_key_env_name)
	if not api_key then
		vim.notify(openai.api_key_env_name .. " not set", vim.log.levels.ERROR)
		return
	end

	local prompt = config.options.prompt .. "\n" .. user_input .. "\n\n" .. sel.text
	local body = vim.fn.json_encode({
		model = openai.model,
		messages = {
			{ role = "system", content = openai.system_role },
			{ role = "user", content = prompt },
		},
	})

	local cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		openai.url,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
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
				vim.notify("Failed to parse OpenAI response", vim.log.levels.ERROR)
				return
			end

			local text = decoded.choices
				and decoded.choices[1]
				and decoded.choices[1].message
				and decoded.choices[1].message.content

			local error = decoded.error and decoded.error.message

			if text then
				ui.open(text, sel)
			elseif error then
				vim.notify("OpenAI response error: " .. error, vim.log.levels.ERROR)
			end
		end,
	})
end

return M
