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
local commands_created = false

---Setup the plugin.
---This is usually called by the user in their config.
---@param opts? table
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

---Print a message using Neovim notifications.
---@param message? string
function M.hello(message)
	local msg = message or M.config.greeting

	vim.notify(("[my_plugin] %s"):format(msg), vim.log.levels.INFO)

	if M.config.verbose then
		vim.print(M.config)
	end
end

---Create user commands.
---This can be called from plugin/my_plugin.lua.
function M.create_commands()
	if commands_created then
		return
	end

	commands_created = true

	vim.api.nvim_create_user_command("MyPluginHello", function(cmd)
		local arg = nil

		if cmd.args and cmd.args ~= "" then
			arg = cmd.args
		end

		M.hello(arg)
	end, {
		nargs = "?",
		desc = "Print a greeting from my_plugin",
	})
end

return M
