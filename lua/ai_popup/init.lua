local gemini = require("ai_popup.gemini")
local openai = require("ai_popup.openai")
local config = require("ai_popup.config")
local selection = require("ai_popup.selection")

local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("AskAI", function(cmd)
		M._run_from_cmdline(cmd.args)
	end, {
		nargs = "*",
		range = true,
		desc = "Ask AI using visual selection",
	})
end

function M._run_from_cmdline(user_input)
	local sel = selection.get_visual_selection_with_range()
	if not sel then
		vim.notify("No visual selection found", vim.log.levels.ERROR)
		return
	end

	-- Use a map for provider lookup
	local providers = {
		gemini = gemini,
		openai = openai,
	}
	local provider = providers[config.options.provider]

	if not provider then
		vim.notify("Invalid provider configured: " .. config.options.provider, vim.log.levels.ERROR)
		return
	end

	provider.request(sel, user_input)
end

return M
