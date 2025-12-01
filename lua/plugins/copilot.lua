return {
	"github/copilot.vim",
	event = "InsertEnter",
	config = function()
		vim.g.copilot_node_command = "~/.nvm/versions/node/v24.11.1/bin/node"
	end,
}
