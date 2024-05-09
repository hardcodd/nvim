local opt = vim.opt

-- stylua: ignore start

-- Global settings
vim.g.mapleader = " "
vim.g.markdown_recommended_style = 0
vim.g.python3_host_prog = "/usr/bin/python3"
vim.cmd("let g:mkdp_auto_start = 1")
vim.cmd("let g:mkdp_auto_close = 1")

-- Basic editor options
opt.clipboard = "unnamedplus"  -- Use system clipboard
opt.mouse = "a"               -- Enable mouse in all modes
opt.termguicolors = true      -- Enable true color support

-- File and buffer handling
opt.autowrite = true          -- Automatically save before commands like :next and :make
opt.confirm = true            -- Confirm to save changes if trying to close unsaved buffer
opt.undofile = true           -- Use undo files
opt.undolevels = 10000        -- Maximum number of undo levels
opt.updatetime = 200          -- Faster completion (4000ms default)
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Window and buffer display options
opt.cursorline = false        -- Disable cursorline for performance in large files
opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Show relative line numbers
opt.signcolumn = "yes"        -- Always show the signcolumn
opt.wrap = false              -- Disable line wrapping
opt.laststatus = 3            -- Global statusline
opt.showmode = false          -- Don't show mode since statusline is enabled
opt.list = true               -- Show invisible characters
opt.listchars:append("eol:↴") -- Appending end-of-line character
opt.fillchars = {             -- Set characters for various UI elements
    foldopen = "",
    foldclose = "",
    fold = "⸱",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}
opt.lazyredraw = true         -- Enable lazy redraw to improve performance

-- Text editing options
opt.expandtab = true          -- Convert tabs to spaces
opt.tabstop = 2               -- Number of spaces a <Tab> counts for
opt.shiftwidth = 2            -- Number of spaces to use for autoindent
opt.smartindent = true        -- Smart autoindenting on new lines
vim.opt.autoindent = true     -- Enable autoindent
opt.smartcase = true          -- Smart case for searching
opt.ignorecase = true         -- Ignore case in search patterns
opt.spelllang = { "en" }      -- Set spelling language to English
opt.incsearch = true          -- Enable incremental search

-- Completion and command options
opt.completeopt = "menu,menuone,noselect"  -- Set completion options
opt.pumblend = 10             -- Popup menu transparency
opt.pumheight = 10            -- Maximum number of items in the popup menu
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.inccommand = "nosplit"    -- Incremental live completion

-- Visual mode and scrolling
opt.sidescrolloff = 8         -- Number of columns of context
opt.scrolloff = 4             -- Number of screen lines to keep above and below the cursor
opt.virtualedit = "block"     -- Allow cursor to move where there is no text in visual block mode
opt.splitbelow = true         -- Horizontal splits will automatically be below
opt.splitright = true         -- Vertical splits will automatically be to the right
opt.winminwidth = 5           -- Minimum window width
opt.timeoutlen = 600          -- Time in milliseconds to wait for a mapped sequence

-- Searching and grep options
opt.grepformat = "%f:%l:%c:%m" -- Format for grep command output
opt.grepprg = "rg --vimgrep"  -- Use ripgrep as grep program

-- Conditionally enable smooth scrolling if Neovim version is 0.10 or newer
if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
end
