local map = vim.keymap.set
local opts = { noremap = false, silent = true }

-- Select all
map("n", "<C-a>", "gg<S-v>G", opts)

-- Increment / Decrement
map("n", "+", "<C-a>", opts)
map("n", "-", "<C-x>", opts)
map("v", "+", "g<C-a>", opts)

-- Undo / Redo
map("n", "u", ":undo<cr>", opts)
map("n", "U", ":redo<cr>", opts)

-- Clear search highlight
map("n", "<escape>", ":noh<cr>", opts)

-- Folding
map("v", "<leader>f", ":fold<cr>", opts) -- fold
map("n", "<leader>f", ":fold<cr>", opts) -- fold
map("n", "<leader>F", "zM", opts) -- fold all
map("n", "<leader>u", "zr", opts) -- unfold
map("n", "<leader>U", "zR", opts) -- unfold all

-- Move cursor with ctrl in insert mode
map("i", "<c-h>", "<Left>", opts)
map("i", "<c-j>", "<Down>", opts)
map("i", "<c-k>", "<Up>", opts)
map("i", "<c-l>", "<Right>", opts)

-- Buffers
map("n", "<Tab>", ":BufferLineCycleNext<cr>", opts) -- next
map("n", "<S-Tab>", ":BufferLineCyclePrev<cr>", opts) -- previous
map("n", "<leader>x", ":bdelete<cr>", opts) -- close
map("n", "<leader>w", ":WSave<cr>", opts) -- save
map("n", "<leader>n", ":enew<cr>", opts) -- new
map("n", "<leader>rf", ":RenameFile<cr>", opts)
map("n", "<leader>rm", ":RemoveFile<cr>", opts)

-- Windows
map("n", "sv", ":vsplit<cr>", opts) -- split vertical
map("n", "ss", ":split<cr>", opts) -- split horizontal
map("n", "<c-h>", "<c-w>h", opts) -- select left
map("n", "<c-j>", "<c-w>j", opts) -- select below
map("n", "<c-k>", "<c-w>k", opts) -- select above
map("n", "<c-l>", "<c-w>l", opts) -- select right
map("n", "<leader>q", ":q<cr>", opts) -- close
map("n", "<c-m-k>", ":resize +5<cr>", opts) -- increase
map("n", "<c-m-j>", ":resize -5<cr>", opts) -- decrease
map("n", "<c-m-h>", ":vertical resize +5<cr>", opts) -- increase
map("n", "<c-m-l>", ":vertical resize -5<cr>", opts) -- decrease

-- Move lines / blocks
map("n", "<a-k>", ":m .-2<cr>==", opts) -- move up
map("n", "<a-j>", ":m .+1<cr>==", opts) -- move down
map("i", "<a-k>", "<Esc>:m .-2<cr>==gi", opts) -- move up
map("i", "<a-j>", "<Esc>:m .+1<cr>==gi", opts) -- move down
map("v", "<a-k>", ":m '<-2<CR>gv-gv", opts) -- move up
map("v", "<a-j>", ":m '>+1<CR>gv-gv", opts) -- move down

-- Diagnostics
map("n", "dl", ":lua vim.diagnostic.open_float()<cr>", opts)
map("n", "dp", ":lua vim.diagnostic.goto_prev()<cr>", opts)
map("n", "dn", ":lua vim.diagnostic.goto_next()<cr>", opts)
map("n", "ds", ":lua vim.diagnostic.setloclist()<cr>", opts)

-- Don't copy the replaced text after pasting in visual mode
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', opts)

-- Change working directory
map("n", "cd", ":cd %:p:h<cr>", opts)

-- Open Netrw
map("n", "<leader>e", ":e .<cr>", opts)

-- Open a file via associated program
local os_type = require("config.utils").get_os_type()
if os_type == "macOS" then
	map("n", "<leader>o", ":!open %<cr>", opts)
elseif os_type == "Linux" then
	map("n", "<leader>o", ":!xdg-open %<cr>", opts)
elseif os_type == "Windows" then
	map("n", "<leader>o", ":!start %<cr>", opts)
end
