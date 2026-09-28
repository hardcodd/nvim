local map = require("functions.keymaps")
local files = require("functions.files")
local diagnostics = require("functions.diagnostics")

-- Search
map.n("<Esc>", map.cmd("nohlsearch"), "Clear search highlight")

-- Mode transitions
map.i("jk", "<Esc>", "Leave Insert mode")

-- Insert navigation
map.i("<C-h>", "<Left>", "Move left")
map.i("<C-j>", "<Down>", "Move down")
map.i("<C-k>", "<Up>", "Move up")
map.i("<C-l>", "<Right>", "Move right")
map.i("<C-S-h>", "<C-Left>", "Move back one word")
map.i("<C-S-j>", "<Down>", "Move down one line")
map.i("<C-S-k>", "<Up>", "Move up one line")
map.i("<C-S-l>", "<C-Right>", "Move forward one word")

-- Diagnostics
map.n("[d", diagnostics.previous, "Previous diagnostic")
map.n("]d", diagnostics.next, "Next diagnostic")

-- File browsing
map.n("<leader>e", files.open, "Open or focus file browser")

-- Buffer and session
map.n("<leader>w", map.cmd("write"), "Save current file")
map.n("<leader>q", map.cmd("confirm qall"), "Quit Neovim")
map.n("<leader>x", map.cmd("confirm bdelete"), "Close current buffer")

-- Telescope
map.n("<leader>ff", map.cmd("Telescope find_files"), "Find files")
map.n("<leader>fg", map.cmd("Telescope live_grep"), "Find text")
map.n("<leader>fb", map.cmd("Telescope buffers"), "Find buffers")
map.n("<leader>fh", map.cmd("Telescope help_tags"), "Find help")
map.n("<leader>ft", map.cmd("TodoTelescope"), "Find TODO comments")

return {
  telescope = {
    i = {
      ["<C-j>"] = "move_selection_next",
      ["<C-k>"] = "move_selection_previous",
      ["<C-S-j>"] = "preview_scrolling_down",
      ["<C-S-k>"] = "preview_scrolling_up",
      ["<C-S-h>"] = "preview_scrolling_left",
      ["<C-S-l>"] = "preview_scrolling_right",
    },
    n = {
      ["<C-j>"] = "move_selection_next",
      ["<C-k>"] = "move_selection_previous",
      ["<C-S-j>"] = "preview_scrolling_down",
      ["<C-S-k>"] = "preview_scrolling_up",
      ["<C-S-h>"] = "preview_scrolling_left",
      ["<C-S-l>"] = "preview_scrolling_right",
    },
  },
}
