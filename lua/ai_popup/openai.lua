local config = require("ai_popup.config")

local M = {}

function M.request(prompt, callback)
	local openai = config.options.openai
	local api_key = os.getenv(openai.api_key_env_name)

	if not api_key then
		vim.notify(openai.api_key_env_name .. " not set", vim.log.levels.ERROR)
		return
	end

	local body = vim.fn.json_encode({
		model = openai.model,
		messages = { role = "system", content = "You are a helpful assistant." },
		{ role = "user", content = prompt },
	})

	local cmd = {
		"curl",
		"-s",
		"-X",
		"POST",
		"https://" .. openai.hostname .. "/" .. openai.version .. "/chat/completions",
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
				callback(vim.split(text, "\n", { plain = true }))
			elseif error then
				vim.notify("OpenAI response error: " .. error, vim.log.levels.ERROR)
			end
		end,
	})
end

return M
