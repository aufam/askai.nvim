local M = {}

---@alias AskAIConfigGemini {model: string, version: "v1" | "v1beta"}
---@alias AskAIConfigOpenAI {url: string, model: string, api_key_env_name: string, system_role: string}
---@alias AskAIProvider {request: function}

---@class AskAIConfig
---@field prompt string
---@field provider? "gemini" | "openai"
---@field gemini AskAIConfigGemini?
---@field openai AskAIConfigOpenAI?

---@type AskAIConfig
local defaults = {
	prompt = "Answer shortly",
}

---@type AskAIConfigGemini
local default_gemini = {
	model = "gemini-2.5-flash-lite",
	version = "v1",
}

---@type AskAIConfigOpenAI
local default_openai = {
	url = "https://api.openai.com/v1/chat/completions",
	model = "gpt-4o-mini",
	api_key_env_name = "OPENAI_API_KEY",
	system_role = "You are a helpful assistant.",
}

---Setup ai-popup.nvim configuration
---@param opts? AskAIConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", defaults, opts or {})
	if M.options.provider == nil then
		if M.options.gemini then
			M.options.provider = "gemini"
		elseif M.options.openai then
			M.options.provider = "openai"
		else
			M.options.provider = "gemini"
		end
	end

	M.options.gemini = vim.tbl_deep_extend("force", default_gemini, M.options.gemini or {})
	M.options.openai = vim.tbl_deep_extend("force", default_openai, M.options.openai or {})
end

return M
