return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPost",
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		signcolumn = true,
		on_attach = function(buffer)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
			end

      -- stylua: ignore start
      -- Actions
      map('n', '<leader>hs', gs.stage_hunk, 'Stage the hunk (Gitsigns)')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset the hunk (Gitsigns)')
      map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Stage selected hunk (Gitsigns)')
      map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Reset selected hunk (Gitsigns)')
      map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer (Gitsigns)')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk (Gitsigns)')
      map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer (Gitsigns)')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk (Gitsigns)')
      map('n', '<leader>hb', function() gs.blame_line{full=true} end, 'Blame line (Gitsigns)')
      map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle current line blame (Gitsigns)')
      map('n', '<leader>hd', gs.diffthis, 'Diff this (Gitsigns)')
      map('n', '<leader>hD', function() gs.diffthis('~') end, 'Diff this (Gitsigns)')
      map('n', '<leader>td', gs.toggle_deleted, 'Toggle deleted (Gitsigns)')

      -- Text object
      map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk (Gitsigns)')
		end,
	},
}
