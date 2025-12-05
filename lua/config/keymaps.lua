local map = vim.keymap.set
local opts = { noremap = false, silent = true }

-- Select all
map("n", "<C-a>", "gg<S-v>G", opts)

-- Increment / Decrement
map("n", "+", "<C-a>", opts)
map("n", "-", "<C-x>", opts)
map("v", "+", "g<C-a>", opts)

-- Undo / Redo
map("n", "u", ":undo<CR>", opts)
map("n", "U", ":redo<CR>", opts)

-- Clear search highlight
map("n", "<escape>", ":noh<CR>", opts)

-- Folding
map("v", "<leader>f", ":fold<CR>", opts) -- fold
map("n", "<leader>f", ":fold<CR>", opts) -- fold
map("n", "<leader>F", "zM", opts) -- fold all
map("n", "<leader>u", "zr", opts) -- unfold
map("n", "<leader>U", "zR", opts) -- unfold all

-- Move cursor with ctrl in insert mode
map("i", "<c-h>", "<Left>", opts)
map("i", "<c-j>", "<Down>", opts)
map("i", "<c-k>", "<Up>", opts)
map("i", "<c-l>", "<Right>", opts)

-- Buffers
map("n", "<Tab>", ":bnext<CR>", opts) -- next
map("n", "<S-Tab>", ":bprev<CR>", opts) -- previous
map("n", "<leader>x", ":bdelete<CR>", opts) -- close
map("n", "<leader>w", ":WSave<CR>", opts) -- save
map("n", "<leader>n", ":enew<CR>", opts) -- new
map("n", "<leader>rf", ":RenameFile<CR>", opts)
map("n", "<leader>rm", ":RemoveFile<CR>", opts)

-- Windows
map("n", "sv", ":vsplit<CR>", opts) -- split vertical
map("n", "ss", ":split<CR>", opts) -- split horizontal
map("n", "<c-h>", "<c-w>h", opts) -- select left
map("n", "<c-j>", "<c-w>j", opts) -- select below
map("n", "<c-k>", "<c-w>k", opts) -- select above
map("n", "<c-l>", "<c-w>l", opts) -- select right
map("n", "<leader>q", ":q<CR>", opts) -- close
map("n", "<c-m-k>", ":resize +5<CR>", opts) -- increase
map("n", "<c-m-j>", ":resize -5<CR>", opts) -- decrease
map("n", "<c-m-h>", ":vertical resize +5<CR>", opts) -- increase
map("n", "<c-m-l>", ":vertical resize -5<CR>", opts) -- decrease

-- Move lines / blocks
map("n", "<M-k>", ":m .-2<CR>==", opts) -- move up
map("n", "<M-j>", ":m .+1<CR>==", opts) -- move down
map("i", "<M-k>", "<Esc>:m .-2<CR>==gi", opts) -- move up
map("i", "<M-j>", "<Esc>:m .+1<CR>==gi", opts) -- move down
map("v", "<M-k>", ":m '<-2<CR>gv-gv", opts) -- move up
map("v", "<M-j>", ":m '>+1<CR>gv-gv", opts) -- move down

-- Diagnostics
map("n", "dl", ":lua vim.diagnostic.open_float()<CR>", opts)
map("n", "dp", ":lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "dn", ":lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "ds", ":lua vim.diagnostic.setloclist()<CR>", opts)

-- Don't copy the replaced text after pasting in visual mode
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', opts)

-- Change working directory
map("n", "cd", ":cd %:p:h<CR>", opts)

-- Open Netrw
map("n", "<leader>e", ":e .<CR>", opts)

-- Telescope
map("n", "<leader>ff", ":Telescope find_files<CR>", opts) -- find files
map("n", "<leader>fw", ":Telescope live_grep<CR>", opts) -- live grep
map("n", "<leader>fb", ":Telescope buffers<CR>", opts) -- buffers
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts) -- help tags
map("n", "<leader>fc", ":Telescope commands<CR>", opts) -- commands
map("n", "<leader>fg", ":Telescope git_files<CR>", opts) -- git files
map("n", "<leader>fr", ":Telescope oldfiles<CR>", opts) -- recent files
map("n", "<leader>ft", ":Telescope file_browser<CR>", opts) -- file browser
map("n", "<leader>gs", ":Telescope git_status<CR>", opts) -- git status
map("n", "<leader>gc", ":Telescope git_commits<CR>", opts) -- git commits
map("n", "<leader>td", ":TodoTelescope<CR>", opts) -- todo

-- Open a file via associated program
local os_type = require("config.utils").get_os_type()
if os_type == "macOS" then
	map("n", "<leader>o", ":!open %<CR>", opts)
elseif os_type == "Linux" then
	map("n", "<leader>o", ":!xdg-open %<CR>", opts)
elseif os_type == "Windows" then
	map("n", "<leader>o", ":!start %<CR>", opts)
end
