# Architecture

The Lua configuration targets Neovim `0.12.5`. Its entry point, `init.lua`,
sets common options, prepares persistent undo, loads the plugin manager, and
then loads the configuration's key mappings.

## Load order

1. `init.lua` sets `mapleader`, basic editor options, a global four-space
   indent, and explicitly enables built-in EditorConfig support with
   `vim.g.editorconfig = true`.
2. `lua/config/lazy.lua` downloads `lazy.nvim` into Neovim's data directory
   when necessary and configures it.
3. `lazy.nvim` loads declarations from `lua/plugins/`, including the public
   `hardcodd/paired-tags.nvim` plugin. That plugin registers its tag handlers
   and `>` and `Enter` mappings before the configuration's mappings load.
   Catppuccin loads at priority `1000`; `functions.theme` starts the macOS
   appearance watcher described in [[Appearance]]. Lualine then configures
   the shared bottom statusline through `functions.statusline`.
4. `lua/keymaps.lua` defines the configuration's mappings. Then
   `filetype plugin indent on` loads Neovim's filetype rules and indent scripts.
5. `lua/autocmds.lua` registers yank highlighting, cursor-position restoration,
   indent guides, and filetype indent settings through `functions.editor`.
   Paired-tag handlers live in `paired-tags.nvim`: the plugin remembers a pair
   before edits and tracks streamed paste boundaries through `vim.paste`.

## Responsibilities

- `lua/config/` — configuration infrastructure.
- `lua/functions/` — configuration functions grouped by purpose; see
  [[Functions]] for the module list and examples.
- `lua/plugins/` — one declaration file per functional plugin group.
- `after/indent/` — Tree-sitter indentation for Vue, TSX, and JSX after
  Neovim's indent scripts, without overriding project indent widths.
- `lua/keymaps.lua` — configuration mappings. `>` and `Enter` tag mappings
  belong to `paired-tags.nvim`.
- `lua/functions/keymaps.lua` — the mapping interface.
- `lua/autocmds.lua` — base autocommands. `functions.autocmds` is their
  registration interface; plugins register their own autocommands.
- `lazy-lock.json` — pinned revisions of installed plugins.
- `tests/` — headless structure and behavior checks.

Related pages: [[Plugins]], [[Keymaps]], [[Operations]].
