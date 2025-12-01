return {
	"willothy/nvim-cokeline",
	dependencies = {
		"nvim-lua/plenary.nvim", -- Required for v0.4.0+
		"nvim-tree/nvim-web-devicons", -- If you want devicons
		"stevearc/resession.nvim", -- Optional, for persistent history
	},
	config = function()
		local get_count = function(buffer, severity)
			local count = 0
			local diagnostic = vim.diagnostic.get(buffer.number)
			for _, diag in ipairs(diagnostic) do
				if diag.severity == severity then
					count = count + 1
				end
			end
			return count
		end
		require("cokeline").setup({
			show_if_buffers_are_at_least = 2,
			components = {
				{
					text = function(buffer)
						return " " .. buffer.devicon.icon
					end,
					fg = function(buffer)
						return buffer.devicon.color
					end,
				},
				{
					text = function(buffer)
						return buffer.filename
					end,
					underline = function(buffer)
						if buffer.is_hovered and not buffer.is_focused then
							return true
						end
					end,
				},
				{
					text = " ",
				},
				{
					text = function(buffer)
						local errors = get_count(buffer, vim.diagnostic.severity.ERROR)
						if errors > 0 then
							return " " .. errors .. " "
						end
						return ""
					end,
					fg = function(buffer)
						return buffer.is_focused and "#ff84a8" or "#d16987"
					end,
				},
				{
					text = function(buffer)
						local warnings = get_count(buffer, vim.diagnostic.severity.WARN)
						if warnings > 0 then
							return " " .. warnings .. " "
						end
						return ""
					end,
					fg = function(buffer)
						return buffer.is_focused and "#fee1a8" or "#bba458"
					end,
				},
				{
					text = function(buffer)
						local infos = get_count(buffer, vim.diagnostic.severity.INFO)
						if infos > 0 then
							return " " .. infos .. " "
						end
						return ""
					end,
					fg = function(buffer)
						return buffer.is_focused and "blue" or "darkblue"
					end,
				},
				{
					text = function(buffer)
						local hints = get_count(buffer, vim.diagnostic.severity.HINT)
						if hints > 0 then
							return "󰌶 " .. hints .. " "
						end
						return ""
					end,
					fg = function(buffer)
						return buffer.is_focused and "#79e4d5" or "#4ec1b6"
					end,
				},
				{
					text = function(buffer)
						if buffer.is_modified then
							return ""
						end
						if buffer.is_hovered then
							return "󰅙"
						end
						return "󰅖"
					end,
					on_click = function(_, _, _, _, buffer)
						buffer:delete()
					end,
				},
				{
					text = " ",
				},
			},
		})
	end,
}
