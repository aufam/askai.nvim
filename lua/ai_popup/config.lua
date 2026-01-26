---@class AIPopupConfigGemini
---@field model string
---@field version string

---@class AIPopupConfigOpenAI
---@field hostname string
---@field api_key_env_name string
---@field model string
---@field version string

---@class AIPopupConfig
---@field prompt string
---@field provider "gemini"|"openai"
---@field gemini AIPopupConfigGemini
---@field openai AIPopupConfigOpenAI

---@type AIPopupConfig
local defaults = {
	prompt = "Answer shorlty\n\n",
	provider = "gemini",
	gemini = { model = "gemini-2.5-flash-lite", version = "v1" },
	openai = { hostname = "api.openai.com", model = "gpt-4o-mini", version = "v1", api_key_env_name = "OPENAI_API_KEY" },
}

local M = {}

---@type AIPopupConfig
M.options = vim.deepcopy(defaults)

---Setup ai-popup.nvim configuration
---@param opts? AIPopupConfig
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M
