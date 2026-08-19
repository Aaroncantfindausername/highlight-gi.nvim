local M = {}
local highlight = require("highlight-gi.highlight")

---Default plugin options.
---@class HighlightgiConfig
---@field default boolean # Use default config
---@field custom_hl_group_opts table<string,any> # Opts table passed to nvim_set_hl() to create custom highlight

-- @type HighlightgiConfig
M.defaults = {
	default = true,
	custom_hl_group_opts = {},
}

---Active plugin configuration.
M.config = vim.deepcopy(M.defaults)

---Prevent duplicate command creation.
local autocmds_created = false

---Setup the plugin.
---This is usually called by the user in their config.
---@param opts? table
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
	if M.config.default then
		vim.cmd("highlight default link LastInsertHighlight DiffText")
	else
		vim.api.nvim_set_hl(0, "LastInsertHighlight", M.config.custom_hl_group_opts)
	end
end

function M.create_autocmds()
	if autocmds_created then
		return
	end

	autocmds_created = true
	vim.api.nvim_create_autocmd("BufWinEnter", {
		callback = function()
			-- M.debug()
			highlight.highlight()
		end,
	})
	vim.api.nvim_create_autocmd({ "TextChanged", "InsertEnter" }, {
		callback = function()
			highlight.clear_highlights()
		end,
	})
end

return M
