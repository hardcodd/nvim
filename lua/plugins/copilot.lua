return {
	"github/copilot.vim",
	event = "InsertEnter",
	config = function()
		vim.g.copilot_node_command = "~/.nvm/versions/node/v25.0.0/bin/node"
	end,
}
