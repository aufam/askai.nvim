local gemini = require("ai_popup.gemini")
local openai = require("ai_popup.openai")
local ui = require("ai_popup.ui")
local config = require("ai_popup.config")
local state = require("ai_popup.state")

local M = {}

function M.setup(opts)
	config.setup(opts)

	vim.api.nvim_create_user_command("AskAI", function(cmd)
		M._run_from_cmdline(cmd.args)
	end, {
		nargs = "*",
		desc = "Ask AI using visual selection",
	})
end

local function get_visual_selection_with_range()
	vim.notify("get ls", vim.log.levels.INFO)
	local _, ls, cs = unpack(vim.fn.getpos("'<"))
	vim.notify("get le", vim.log.levels.INFO)
	local _, le, ce = unpack(vim.fn.getpos("'>"))

	vim.notify("get lines", vim.log.levels.INFO)
	local lines = vim.fn.getline(ls, le)
	if #lines == 0 then
		return nil
	end

	lines[1] = string.sub(lines[1], cs)
	lines[#lines] = string.sub(lines[#lines], 1, ce)

	return {
		text = table.concat(lines, "\n"),
		range = { ls, le },
	}
end

function M._run_from_cmdline(user_input)
	local sel = state.selection
	if not sel then
		vim.notify("No visual selection found", vim.log.levels.ERROR)
		return
	end

	-- clear state immediately (important)
	state.selection = nil

	local prompt = config.options.prompt .. "\n" .. user_input .. "\n\n" .. sel.text

	vim.notify("_run_from_cmdline", vim.log.levels.INFO)
	gemini.request(prompt, function(response_lines)
		ui.open(response_lines, {
			on_replace = function(lines)
				vim.api.nvim_buf_set_lines(0, sel.range[1] - 1, sel.range[2], false, lines)
			end,
		})
	end)
end

function M.ask_visual()
	vim.notify("ask visual get_visual_selection_with_range", vim.log.levels.INFO)
	local sel = get_visual_selection_with_range()
	if not sel then
		return
	end

	-- store selection temporarily
	state.selection = sel

	-- open command-line prompt
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":AskAI ", true, false, true), "n", false)
end

function M.ask()
	local sel = get_visual_selection_with_range()
	if not sel then
		vim.notify("AI-Popup: Empty selection", vim.log.levels.ERROR)
		return
	end

	local prompt = config.options.prompt .. sel.text
	vim.notify(prompt, vim.log.levels.INFO)

	local provider
	if config.options.provider == "gemini" then
		provider = gemini
	elseif config.options.provider == "openai" then
		provider = openai
	end

	provider.request(prompt, function(response_lines)
		ui.open(response_lines, {
			on_replace = function(lines)
				vim.api.nvim_buf_set_lines(0, sel.range[1] - 1, sel.range[2], false, lines)
			end,
		})
	end)
end

return M
