local config_directory = vim.fn.getcwd()

local expected_files = {
  "Neovim Knowlage/.obsidian/app.json",
  ".gitignore",
  "README.md",
  "Neovim Knowlage/Home.md",
  "Neovim Knowlage/Architecture.md",
  "Neovim Knowlage/Plugins.md",
  "Neovim Knowlage/Keymaps.md",
  "Neovim Knowlage/Operations.md",
  "Neovim Knowlage/Functions.md",
  "Neovim Knowlage/Appearance.md",
}

for _, relative_path in ipairs(expected_files) do
  assert(vim.fn.filereadable(config_directory .. "/" .. relative_path) == 1, relative_path .. " is missing")
end

local gitignore_source = table.concat(vim.fn.readfile(config_directory .. "/.gitignore"), "\n")
local readme_source = table.concat(vim.fn.readfile(config_directory .. "/README.md"), "\n")
local home_source = table.concat(vim.fn.readfile(config_directory .. "/Neovim Knowlage/Home.md"), "\n")
local plugins_source = table.concat(vim.fn.readfile(config_directory .. "/Neovim Knowlage/Plugins.md"), "\n")
local keymaps_source = table.concat(vim.fn.readfile(config_directory .. "/Neovim Knowlage/Keymaps.md"), "\n")

assert(gitignore_source:find("nvim.log", 1, true), ".gitignore must exclude Neovim logs")
assert(gitignore_source:find("workspace.json", 1, true), ".gitignore must exclude the Obsidian workspace layout")
assert(readme_source:find("https://github.com/hardcodd/nvim.git", 1, true), "README lacks the clone URL")
assert(readme_source:find("Neovim%20Knowlage/Operations.md", 1, true), "README lacks the operational guide")
assert(home_source:find("[[Architecture]]", 1, true), "knowledge base home lacks an architecture link")
assert(home_source:find("[[Functions]]", 1, true), "knowledge base home lacks a functions link")
assert(home_source:find("[[Appearance]]", 1, true), "knowledge base home lacks an appearance link")
assert(plugins_source:find("telescope.nvim", 1, true), "plugin inventory lacks Telescope")
assert(keymaps_source:find("Space q", 1, true), "keymap reference lacks the quit mapping")
assert(keymaps_source:find("Space x", 1, true), "keymap reference lacks the buffer-close mapping")
assert(keymaps_source:find("j k", 1, true), "keymap reference lacks the Insert-mode exit mapping")
