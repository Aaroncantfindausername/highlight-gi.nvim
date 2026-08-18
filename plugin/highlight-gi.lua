-- Prevent the plugin from being loaded twice.
if vim.g.loaded_my_plugin then
	return
end

vim.g.loaded_my_plugin = true

require("highlight-gi").create_autocmds()
