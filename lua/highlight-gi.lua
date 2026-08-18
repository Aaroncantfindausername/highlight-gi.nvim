local M = {}

---Default plugin options.
---@class MyPluginConfig
---@field greeting string
---@field verbose boolean
M.defaults = {
	greeting = "Hello from my_plugin!",
	verbose = false,
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
end

M.ns = vim.api.nvim_create_namespace("highlight-gi")

function M.highlight()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local rc = vim.api.nvim_buf_get_mark(0, "^")
	-- rc is 0,0 if mark doesn't exist
	local row, col = rc[1], rc[2]
	if row == 0 and col == 0 then
		return
	end
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
	local line_len = #line
	local start_col = col - 1
	local end_col = col
	if start_col < 0 then
		start_col = 0
		end_col = end_col + 1
	end
	if end_col > line_len then
		end_col = line_len
		start_col = math.max(0, line_len - 1)
	end
	M.clear_highlights()
	vim.api.nvim_buf_set_extmark(0, M.ns, row - 1, start_col, {
		end_row = row - 1,
		end_col = end_col,
		hl_group = "Substitute",
		right_gravity = false,
		end_right_gravity = false,
		strict = false,
	})
end
-- testing testin

function M.debug()
	local rc = vim.api.nvim_buf_get_mark(0, "^")
	print(vim.inspect(rc))
	local bufnr = vim.api.nvim_get_current_buf()
	print(vim.inspect(vim.bo[bufnr].buftype))
end

function M.clear_highlights()
	vim.api.nvim_buf_clear_namespace(0, M.ns, 0, -1)
end

function M.create_autocmds()
	if autocmds_created then
		return
	end

	autocmds_created = true
	vim.api.nvim_create_autocmd("BufWinEnter", {
		callback = function()
			-- M.debug()
			M.highlight()
		end,
	})
	vim.api.nvim_create_autocmd({ "TextChanged", "InsertEnter" }, {
		callback = function()
			M.clear_highlights()
		end,
	})
end

return M
