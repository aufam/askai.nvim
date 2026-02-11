local gemini = require("askai.gemini")
local openai = require("askai.openai")
local anthropic = require("askai.anthropic")
local config = require("askai.config")
local selection = require("askai.selection")

local M = {}

function M.setup(opts)
	config.setup(opts)

	---@param cmd vim.api.keyset.create_user_command.command_args
	vim.api.nvim_create_user_command("AskAI", function(cmd)
		M.askai(cmd.args, cmd.range)
	end, {
		nargs = "*",
		range = true,
		desc = "askai: Ask AI using visual selection",
	})

	vim.api.nvim_create_user_command("AskAIModel", function(cmd)
		if cmd.args ~= "" and not M.set_model(cmd.args) then
			vim.api.nvim_echo({ { "Unknown model: " .. cmd.args } }, false, { err = true })
		end
		print("Current AI model: " .. M.get_model())
	end, {
		nargs = "?",
		desc = "askai: Get or set the current AI model",
	})

	vim.api.nvim_create_user_command("AskAIPrompt", function(cmd)
		if cmd.args ~= "" then
			config.options.prompt = cmd.args
		end
		print("Current prompt: " .. config.options.prompt)
	end, {
		nargs = "?",
		desc = "askai: Get or set default prompt",
	})

	vim.api.nvim_create_user_command("AskAIProvider", function(cmd)
		if cmd.args == "gemini" or cmd.args == "openai" or cmd.args == "anthropic" then
			config.options.provider = cmd.args
		elseif cmd.args ~= "" then
			vim.api.nvim_echo({ { "Unknown provider: " .. cmd.args } }, false, { err = true })
		end
		print("Current AI provider: " .. config.options.provider)
	end, {
		nargs = "?",
		desc = "Get or set the current AI provider",
		complete = function()
			return { "gemini", "openai", "anthropic" }
		end,
	})

	vim.api.nvim_create_user_command("AskAIGeminiVersion", function(cmd)
		if cmd.args ~= "" then
			config.options.gemini.version = cmd.args
		end
		print("Current Gemini version: " .. config.options.gemini.version)
	end, {
		nargs = "?",
		desc = "Get or set the current AI provider",
		complete = function()
			return { "gemini", "openai", "anthropic" }
		end,
	})

	vim.api.nvim_create_user_command("AskAIGeminiVersion", function(cmd)
		if cmd.args ~= "" then
			config.options.gemini.version = cmd.args
		end
		print("Current Gemini version: " .. config.options.gemini.version)
	end, {
		nargs = "?",
		desc = "Get or set the current Gemini API version",
	})

	vim.api.nvim_create_user_command("AskAIOpenAIURL", function(cmd)
		if cmd.args ~= "" then
			config.options.openai.url = cmd.args
		end
		print("Current OpenAI URL: " .. config.options.openai.url)
	end, {
		nargs = "?",
		desc = "Get or set the current OpenAI URL",
	})

	vim.api.nvim_create_user_command("AskAIOpenAIAPIKeyEnvName", function(cmd)
		if cmd.args ~= "" then
			config.options.openai.api_key_env_name = cmd.args
		end
		print("Current OpenAI API key env name: " .. config.options.openai.api_key_env_name)
	end, {
		nargs = "?",
		desc = "Get or set the current OpenAI API key env name",
	})

	vim.api.nvim_create_user_command("AskAIOpenAISystemRole", function(cmd)
		if cmd.args ~= "" then
			config.options.openai.system_role = cmd.args
		end
		print("Current OpenAI system role: " .. config.options.openai.system_role)
	end, {
		nargs = "?",
		desc = "Get or set the current OpenAI system role",
	})

	vim.api.nvim_create_user_command("AskAIAnthropicVersion", function(cmd)
		if cmd.args ~= "" then
			config.options.anthropic.anthropic_version = cmd.args
		end
		print("Current Anthropic version: " .. config.options.anthropic.anthropic_version)
	end, {
		nargs = "?",
		desc = "Get or set the current Anthropic version",
	})

	vim.api.nvim_create_user_command("AskAIAnthropicVersion", function(cmd)
		if cmd.args ~= "" then
			config.options.anthropic.anthropic_version = cmd.args
		end
		print("Current Anthropic version: " .. config.options.anthropic.anthropic_version)
	end, {
		nargs = "?",
		desc = "Get or set the current Anthropic version",
	})

	vim.api.nvim_create_user_command("AskAIAnthropicMaxTokens", function(cmd)
		if cmd.args ~= "" then
			local n = tonumber(cmd.args)
			if n then
				config.options.anthropic.max_tokens = n
			else
				vim.api.nvim_echo({ { "Canot convert to number: " .. cmd.args } }, false, { err = true })
			end
		end
		print("Current Anthropic version: " .. config.options.anthropic.max_tokens)
	end, {
		nargs = "?",
		desc = "Get or set the current Anthropic version",
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
---@param range integer
function M.askai(user_input, range)
	local sel = selection.get_visual_selection_with_range(range)
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
