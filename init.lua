-- Dependency-free defaults for interactive editing.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.editorconfig = true

local options = {
  backup = false,
  completeopt = "menu,menuone,noselect",
  confirm = true,
  cursorline = true,
  expandtab = true,
  fileencoding = "utf-8",
  ignorecase = true,
  mouse = "a",
  number = true,
  pumheight = 10,
  relativenumber = true,
  scrolloff = 8,
  showmode = false,
  sidescrolloff = 8,
  signcolumn = "yes",
  shiftwidth = 4,
  smartcase = true,
  smartindent = true,
  softtabstop = -1,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  tabstop = 4,
  timeoutlen = 300,
  termguicolors = true,
  undofile = true,
  updatetime = 250,
  wrap = false,
}

for name, value in pairs(options) do
  vim.opt[name] = value
end

local undo_directory = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undo_directory) == 0 then
  vim.fn.mkdir(undo_directory, "p")
end
vim.opt.undodir = undo_directory

vim.cmd("syntax enable")
require("config.lazy")
require("keymaps")
vim.cmd("filetype plugin indent on")
require("autocmds")
