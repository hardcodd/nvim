# Appearance

Контраст цветных плашек `TODO:` и `FIXME:` в Latte и Mocha описан в
[[Комментарии]].

После изменения `custom_highlights` в `functions.theme` выполни
`:CatppuccinCompile` и перезапусти Neovim, чтобы обновить скомпилированный
кэш темы.

The configuration uses [Catppuccin v2.0.0](https://github.com/catppuccin/nvim/tree/v2.0.0):
light Latte and dark Mocha. The version and revision are pinned in the plugin
declaration and `lazy-lock.json`. `lazy.nvim` downloads the theme on first
launch; appearance changes need no network access after installation.

The theme loads at priority `1000`. Its built-in highlighting covers
Tree-sitter and LSP diagnostics. `auto_integrations = true` enables integrations
for recognized plugins in the `lazy.nvim` configuration, including Telescope.
Some future plugins may require separate theme configuration.

## Indent guides

In a normal buffer, leading tabs appear as thin `│` lines. Leading spaces
before code show the same line at the start of each complete `shiftwidth`
level; only the spaces in an incomplete final level appear as `·` dots. With
a two-space step, two spaces render as `│ `, three as `│ ·`, and four as
`│ │ `. Lines use the subdued `surface1` color. Dots in incomplete levels
use `overlay0` from Latte or Mocha. Whitespace-only lines, spaces inside
code, and special buffers have no guides. File content is unchanged.

The first transition between leading tabs and spaces also receives a subtle
`surface0` background. `functions.editor.update_indent_guides()` refreshes
the display when the buffer, window, or indent options change. When
`shiftwidth=0`, it uses `tabstop`. Space guides are rendered only for visible
lines, without placing marks in the buffer or requiring another plugin. An
incomplete level may be intentional continuation alignment; the dots only
show its number of spaces.

The default indent is four spaces: `shiftwidth=4`, `tabstop=4`,
`softtabstop=-1`, and `expandtab`. HTML, Django HTML (`htmldjango`), CSS,
SCSS, JavaScript, TypeScript, JSX/TSX, JSON, JSONC, YAML, XML, Vue, Svelte,
Markdown, TOML, and Lua use two spaces. Python, C/C++, C#, Java, Rust, shell
scripts, and unlisted types use four spaces. Go and Makefiles retain real
tabs at eight columns. These rules apply both at startup and when files open
later. They affect new indentation without rewriting existing text. A
project's `.editorconfig` takes precedence.

Neovim's standard indent scripts are enabled. For HTML and `htmldjango`,
they indent after an opening tag. With the cursor between adjacent matching
tags, such as `<div>|</div>`, one `Enter` creates a content line at the
buffer's current indent step and moves the closing tag to the next line.
The step includes `.editorconfig` settings. Quoted `<` or `>` characters in
opening-tag attributes do not prevent this split.

## Long lines

By default, `wrap = false`: a long line stays on one display line and the
editor scrolls horizontally. File content is unchanged. Use `:setlocal wrap`
to wrap only the current window; `:setlocal nowrap` restores the default.

## System appearance

`lua/functions/theme.lua` reads global macOS settings through
`/usr/bin/defaults read -g` at startup, on focus return, and every three
seconds. `AppleInterfaceStyle = Dark` selects Mocha; a missing key selects
Latte. macOS automatic appearance is followed when the system changes its
effective style. The configuration does not change macOS or terminal settings.

The read is asynchronous, with a two-second timeout and no overlapping
requests. On failure, the previous theme remains and the next check retries.
The first frame may briefly use the previous `background` while awaiting a
system response. On other operating systems, Neovim's `background` is used;
system appearance synchronization is not implemented there.

## Statusline

`lualine.nvim` installs automatically. One shared statusline shows data for
the active window and follows the Latte or Mocha palette. Colored blocks meet
at diagonal `◣` and `◢` joins; thin `╱` and `╲` symbols separate items.
Outer edges remain straight. These are standard Unicode characters and do
not require a Nerd Font, although their exact shape depends on the terminal
font.

- Left: mode, Git branch, and line changes marked `+`, `~`, or `-`.
- Main area: path relative to the Git project root, or to the working
  directory outside Git. `[+]` marks unsaved changes; `[RO]` marks a
  read-only file or unmodifiable buffer.
- Right: `E:` and `W:` counts for the current buffer, filetype, encoding,
  and cursor line/column. Encoding comes from `fileencoding`, falling back
  to `encoding` when empty. `[BOM]` marks a byte-order mark. The statusline
  does not change file encoding.
- During search: current match and total count. During selection: selection
  size. With an attached LSP: client name and activity indicator.

Empty indicators take no space. Error and warning counts are absent when
there is no diagnostic source; the statusline does not install language
servers. Git counts compare saved changes in the current file with the index;
unsaved changes are marked separately with `[+]`.

Below 100 columns, Git counts and LSP are hidden. Below 80, branch and
filetype are hidden too. Below 60, encoding and contextual counters are also
hidden, while mode and filename are shortened. Long paths shrink while
retaining status markers. Configuration lives in
`lua/functions/statusline.lua`; its declaration is in
`lua/plugins/statusline.lua`. The revision is pinned in the declaration and
lockfile.

## Verifying appearance

Restart Neovim and change appearance in macOS settings. The theme should
switch within about three seconds without restarting. Open a source file
and Telescope with `Space f f` to assess legibility.

`tests/theme_spec.lua` checks transitions, errors, stale responses, and
stopping the watcher. `tests/theme_integration.lua` checks both actual
palettes and Tree-sitter, diagnostic, and Telescope highlight groups after
loading the configuration. Visual assessment in your terminal and switching
macOS appearance through its interface remain manual checks.

`tests/statusline_spec.lua` checks width adaptation, paths, and state
markers. `tests/statusline_integration.lua` checks the rendered line in both
palettes with diagnostics, search, selection, split windows, and an empty
buffer. LSP data and Git change counts are simulated in this test.

`tests/indent_guides_spec.lua` checks lines and dots at different indent
widths, the `tabstop` fallback, tabs, mixed indentation, special buffers,
window switches, edits, and Lua settings. Its appearance in your terminal
remains a manual check.

Related pages: [[Plugins]], [[Functions]], [[Operations]].
