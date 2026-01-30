local gemini = require("askai.gemini")
local openai = require("askai.openai")
local anthropic = require("askai.anthropic")
local config = require("askai.config")
local selection = require("askai.selection")

local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("AskAI", function(cmd)
		M.askai(cmd.args)
	end, {
		nargs = "*",
		range = true,
		desc = "Ask AI using visual selection",
	})

	vim.api.nvim_create_user_command("AskAIModel", function(cmd)
		if cmd.args == "" then
			-- get
			local model = M.get_model()
			if model then
				print("Current AI model: " .. model)
			end
		else
			-- set
			if M.set_model(cmd.args) then
				print("AI model set to: " .. cmd.args)
			end
		end
	end, {
		nargs = "?",
		desc = "Get or set the current AI model",
	})

	vim.api.nvim_create_user_command("AskAIProvider", function(cmd)
		if cmd.args == "" then
			-- get
			print("Current AI provider: " .. config.options.provider)
		elseif cmd.args == "gemini" or cmd.args == "openai" or cmd.args == "anthropic" then
			-- set
			config.options.provider = cmd.args
			print("Current AI provider: " .. config.options.provider)
		else
			vim.api.nvim_echo({ { "Unknown provider: " .. cmd.args } }, false, { err = true })
		end
	end, {
		nargs = "?",
		desc = "Get or set the current AI provider",
		complete = function()
			return { "gemini", "openai", "anthropic" }
		end,
	})
end

---@return AskAIProvider | nil
function M.get_provider()
	local providers = {
		gemini = gemini,
		openai = openai,
		anthropic = anthropic,
	}
	local provider = providers[config.options.provider]

	if not provider then
		vim.notify("Invalid provider configured: " .. config.options.provider, vim.log.levels.ERROR)
		return nil
	end

	return provider
end

---@param user_input string
function M.askai(user_input)
	local sel = selection.get_visual_selection_with_range()
	if not sel then
		return
	end

	local provider = sel and M.get_provider()
	if not provider then
		return
	end

	provider.request(sel, user_input)
end

---@return string?
function M.get_model()
	local models = {
		gemini = config.options.gemini.model,
		openai = config.options.openai.model,
		anthropic = config.options.anthropic.model,
	}
	local model = models[config.options.provider]

	if not model then
		vim.notify("Invalid provider configured: " .. config.options.provider, vim.log.levels.ERROR)
		return nil
	end

	return model
end

---@param new_model string
function M.set_model(new_model)
	if config.options.provider == "gemini" then
		config.options.gemini.model = new_model
	elseif config.options.provider == "openai" then
		config.options.openai.model = new_model
	elseif config.options.provider == "anthropic" then
		config.options.anthropic.model = new_model
	else
		return false
	end
	return true
end

return M
