# Functions and key mapping

All functions owned by this configuration live in `lua/functions/`.
Configuration files require them by name; test helpers remain in `tests/`.
Add new logic to the appropriate module, its mapping to the corresponding
block in `lua/keymaps.lua`, and a base autocommand to `lua/autocmds.lua`.
Paired-tag handlers live in the separate `paired-tags.nvim` plugin; see
[[Plugins#Paired symbols and tags]].

## Modules

| Module | Purpose |
| --- | --- |
| `functions.keymaps` | Define mappings and wrap commands. |
| `functions.autocmds` | Create groups and register autocommands. |
| `functions.files` | Open or reuse the file browser with `open()`. |
| `functions.diagnostics` | Move between diagnostics with `previous()` and `next()`. |
| `functions.editor` | Highlight yanked text, restore cursor position, display indent guides, and set filetype indentation. |
| `functions.treesitter` | Configure highlighting and automatic parser installation with `setup()`; configure Vue, TSX, and JSX indentation after standard scripts with `configure_indentation(buf)`. |
| `functions.plugins` | Configure Telescope, preview scrolling and tab width, and `nvim-autopairs` through `telescope()`, `telescope_preview_tabs()`, and `autopairs()`. |
| `functions.editorconfig` | Resolve tab width from a project's `.editorconfig` for previews with `tab_width(path)`. |
| `functions.theme` | Configure Catppuccin and watch macOS appearance with `setup()`, `refresh()`, and `stop()`. |
| `functions.statusline` | Configure lualine, project paths, and width-dependent statusline content. |

Requiring a module does not configure its plugin. The plugin manager calls
the setup function after loading the dependency. The former
`lua/config/treesitter.lua` moved to `lua/functions/treesitter.lua`.

## Adding a mapping

`lua/keymaps.lua` already requires `map`, `files`, and `diagnostics` at the top.
A Normal-mode mapping needs one line:

```lua
map.n("<leader>e", files.open, "Open or focus file browser")
```

Pass a function without calling it: `files.open`, not `files.open()`.
A string action represents a key sequence:

```lua
map.i("jk", "<Esc>", "Leave Insert mode")
```

Wrap commands explicitly in `map.cmd`, without a leading `:` or trailing Enter:

```lua
map.n("<leader>ff", map.cmd("Telescope find_files"), "Find files")
```

## Modes and options

Signature: `map.n(keys, action, description, options?)`.
Available mode helpers are `n`, `i`, `v`, `x`, `s`, `o`, `c`, and `t`: Normal,
Insert, Visual plus Select, Visual only, Select, operator-pending,
command-line, and Terminal mode, respectively.

Use `map.set` for multiple modes:

```lua
map.set({ "n", "x" }, "<leader>y", '"+y', "Copy to clipboard")
```

The last argument accepts standard `vim.keymap.set` options:

```lua
map.n("<leader>w", map.cmd("write"), "Save buffer", { buf = 0 })
```

`buf = 0` limits the mapping to the current buffer at registration time;
without it, the mapping is global. Standard options such as `expr`, `nowait`,
and `remap` are also available. Defaults are `silent = true` and
`remap = false`; callers may override them. The passed options table is not
modified.

Keys and description are required and must be nonempty. The third-argument
description takes precedence over `options.desc` and appears in Neovim's
mapping inspection tools. `map.cmd` accepts a nonempty, single-line command.
Neovim's API validates the remaining constraints.

Registering the same mapping again for the same mode and scope replaces the
earlier mapping, as in `vim.keymap.set`. There is no extra registry or
automatic loading of function files. Except where listed in [[Keymaps]], the
examples above illustrate the interface; they do not add mappings themselves.

## Autocommands

Base autocommands live in `lua/autocmds.lua`. Use `functions.autocmds` for a
new group and handler:

```lua
local auto = require("functions.autocmds")
local editor = require("functions.editor")
local group = auto.group("BaseConfiguration")
auto.set("TextYankPost", editor.highlight_yank, "Highlight copied text", { group = group })
```

`auto.group(name)` clears the group's previous autocommands when configured
again. `auto.set(events, callback, description, options?)` accepts one event
or a list, a callback, a nonempty description, and standard
`nvim_create_autocmd` options such as `group`, `pattern`, `buf`, and `once`.
It does not modify the options table. The explicit callback and description
take precedence over the corresponding fields in that table. Group name,
event, and description cannot be empty. Neovim validates unknown events and
incompatible options.

The theme, statusline, and Tree-sitter modules create their autocommands
through the same interface in their respective `setup()` functions, preserving
their load timing. `paired-tags.nvim` registers its own autocommands.

Related pages: [[Architecture]], [[Keymaps]], [[Operations]].
