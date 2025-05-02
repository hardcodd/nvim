local M = {}

-- Returns the OS name (macOS, Linux, Windows)
M.get_os_type = function()
	if vim.fn.has("mac") == 1 then
		return "macOS"
	elseif vim.fn.has("unix") == 1 then
		return "Linux"
	else
		return "Windows"
	end
end

M.augroup = function(name)
	return vim.api.nvim_create_augroup("hardcodd_" .. name, { clear = true })
end

return M
