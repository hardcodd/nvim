local o = vim.o
local cmd = vim.cmd

-- Encoding
o.encoding = "utf-8"

-- Termguicolors
o.termguicolors = true

-- Line numbers
o.number = true
o.relativenumber = true

-- Cursor
o.cursorline = true
o.cursorlineopt = 'number'

-- Cmd height
o.cmdheight = 1

-- Enable mouse
o.mouse = "a"

-- Show editing file in terminal title
o.title = true

-- Set scrolling offset
o.scrolloff = 10
o.sidescrolloff = 10

-- Set vertical ruller
o.colorcolumn = "80"

-- Use system clipboard
o.clipboard = "unnamedplus"

-- Confirm actions
o.confirm = true

-- Disable backup files
o.backup = false
o.wb = false
o.swapfile = false

-- Indentation
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = false
o.smartindent = true
o.autoindent = true

-- Lines wrapping
o.wrap = false

-- Don't redraw while executing macros (good perfomance config)
o.lazyredraw = true

-- Searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- Filetype plugin indent
cmd("filetype plugin indent on")

-- Shortmess
vim.o.shortmess = vim.o.shortmess .. "c"

-- Hidden buffers
o.hidden = true

-- Which wrap
-- o.whichwrap = 'b,s,<,>,[,],h,l'

-- Pumheight
o.pumheight = 10

-- Split options
o.splitbelow = true
o.splitright = true

-- Show TabLine
-- o.showtabline = 2

-- Showmode
o.showmode = false

-- Signcolumn
o.signcolumn = "yes"
