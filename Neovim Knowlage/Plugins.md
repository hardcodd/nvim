# Plugins

## Theme and statusline

`nvim-lualine/lualine.nvim` draws the shared bottom statusline with mode, Git,
file, and diagnostic data. It uses the Catppuccin palette and needs no icon
plugin. It installs on first launch; its revision is pinned in the plugin
declaration and `lazy-lock.json`.

`catppuccin/nvim` version `v2.0.0` installs automatically. Latte and Mocha
follow macOS appearance, and automatic plugin integration detection is on.
See [[Appearance]] for settings and limits.

## Plugin manager

`folke/lazy.nvim` bootstraps into
`stdpath("data") .. "/lazy/lazy.nvim"` if missing. It then installs missing
plugins on Neovim's first launch.

`lazy-lock.json` records tested commit SHAs. Commit it with plugin-list
changes or updates so a clone can reproduce the installed revisions.

## Paired symbols and tags

`windwp/nvim-autopairs` version `0.10.0` loads on entering Insert mode. Its
release revision is pinned in `lazy-lock.json`. It pairs brackets, single
and double quotes, and backticks. Typing an existing closer skips over it;
`Backspace` removes an empty pair. Its Enter mapping is disabled to preserve
the HTML tag indentation behavior. Configuration lives in
`functions.plugins.autopairs()`.

The separate public plugin
[`hardcodd/paired-tags.nvim`](https://github.com/hardcodd/paired-tags.nvim)
closes and jointly renames tags. It is declared in
`lua/plugins/paired_tags.lua`, loads at startup through `lazy.nvim`, and is
pinned in `lazy-lock.json`. It also maps `>` and `Enter`, and handles Enter
between matching HTML tags using the active indent settings. Its full
features and limits are in the plugin's
[README](https://github.com/hardcodd/paired-tags.nvim/blob/main/README.md).
It uses Tree-sitter for HTML, XML, `htmldjango`, JSX/TSX, Vue, Svelte, and
HTML embedded in Markdown. The language parser must be installed; embedded
HTML also needs the `html` parser. Without a parser, ordinary tag editing
still works, but automatic tag actions do not run.

Обход ограничения запроса подсветки глубоко вложенного HTML описан в
[[Подсветка HTML]]. Он не меняет сопоставление тегов в `paired-tags.nvim`.

Typing `>` after an opener inserts a closer if one is missing. This completes
before the next key, so a fast `Enter` immediately after the opener creates
a line between the pair. Empty XML elements and HTML void elements are not
closed again. In JSX/TSX, Vue, and Svelte, component names `Input`, `Link`,
`Meta`, `Source`, and `BR` are not treated as HTML void elements.

JSX/TSX supports dotted component names, nested components,
`<MenuComponent />`, names with `$`, and fragments `<>...</>`. Comparisons
and type parameters remain ordinary code. TSX type arguments are preserved
when a component is renamed. Before inserting a closer, the plugin checks
that the typed `>` really ends an opener: `>` inside an existing attribute
does not insert a closer inside quotes, and a `>` omitted from the parser's
view is not treated as a real completion. XML case and UTF-8 tag names are
preserved.

Changing an opening or closing tag name updates its partner, including tags
with attributes and a new name matching an ancestor. Before a Normal-mode
edit, the module records the original pair by buffer positions. This keeps
the pair through temporarily invalid XML, Svelte, Vue, nested HTML, or TSX
trees. Lexical search is a fallback when the parser cannot associate a pair;
strings, comments, and regex inside expressions must not become tags during
that search.

If JSX temporarily parses as an error, a tag-boundary search can recover the
original pair while treating JSX strings and comparisons as code. When an
opening name is fully deleted before its attributes, the remembered pair
stays attached to the original tag, so replacing an outer name does not
change nested closers. The pair is also captured on moving to another name
in Insert mode. In XML it survives a separate `diw` while the deleted name
remains empty, even before spaces or a newline preceding `>`, and is used
when the new name is typed or pasted.

During streamed `nvim_paste`, the module waits for the final chunk and does
not add closers between chunks. This prevents extra closers in complete
fragments delivered in pieces. For HTML `script` and `style`, the parser
temporarily sees a renamed closing tag as text; the remembered pair lets the
plugin update the opener. Closer-like text inside a string or comment does
not alter that pair.

An unfinished new tag name is not synchronized until its own `>` is typed;
ancestor closers remain unchanged. The `>` in a following `</p>` does not
complete an unfinished `<address`. Pair search skips an unfinished nested
tag, while quoted attribute or JSX-expression `<` and `>` characters do
not end an outer tag. For misnamed nested tags, the module checks delimiter
structure because the syntax tree may temporarily associate a closer with
the wrong nesting level.

When creating a tag inside a same-name parent, the existing parent closer's
position is recorded before `<` is inserted. The child still gets its own
closer after leaving Insert mode or pasting. HTML optional endings for
`li`, `p`, `option`, table rows, and cells are considered when renaming a
container.

Content in `textarea`, `title`, and other HTML text elements is not
auto-closed as markup. Markdown inline and fenced code remains literal,
including fences marked `html`. Editing tag-like fragments there or in Vue
interpolation strings does not rename another tag, including strings that
continue onto the next line. A real `textarea` closer remains editable even
when its content contains tag-like text. Quotes in JavaScript comments or
regex do not terminate a Vue interpolation string; the string may continue
on the next line. A finished HTML comment containing `{{` does not obscure
a following real Vue tag. XML processing instructions and `ENTITY` values,
Django HTML line and block comments, and CSS strings in multiline `style`
blocks do not form tag pairs; editing tag-like text there changes only the
typed name.

The plugin cannot promise recovery of arbitrarily damaged markup. If
Tree-sitter and lexical search cannot identify a pair unambiguously, it
skips the automatic action. JSX requires built-in elements to close
explicitly with a self-closing form such as `<img />`.

## Telescope

`nvim-telescope/telescope.nvim` is declared in `lua/plugins/telescope.lua`
with version `"*"`; its exact revision is pinned in `lazy-lock.json`.
`nvim-lua/plenary.nvim` is required. No optional native extensions are
configured, avoiding a compiler requirement for Telescope installation.

`live_grep` requires the ripgrep executable `rg`. The current development
environment has ripgrep `15.2.0`.

Related mappings: [[Keymaps#Telescope]].

`layout_config.scroll_speed = 2` in `lua/functions/plugins.lua` sets preview
scrolling to two lines vertically or two columns horizontally.

After `TelescopePreviewerLoaded`, a preview inherits `tabstop` and
`vartabstop` from an already loaded buffer for the same file. For a file not
yet open, it uses the filetype's normal tab width: two columns for web files
and Lua, four by default, and eight for Go and Makefiles. If no filetype is
provided, the global value is used.

A matching `.editorconfig` then overrides tab width: explicit `tab_width`
takes precedence over numeric `indent_size`. This also works before opening
the file. Sections, nested settings, `root = true`, and `unset` are handled;
settings are reread when the preview updates. `functions.editorconfig`
resolves tab width alone using Neovim 0.12.5's built-in rules, because its
parser has no public interface for a path without a normal buffer. Compare
results with the native handler through `tests/editorconfig_spec.lua` when
updating Neovim. Neovim caches filetype settings; an unopened file's modeline
is not read separately. Text, ordinary spaces, and guides remain unchanged,
and EditorConfig save hooks are not added to previews.

## Syntax highlighting

`nvim-treesitter/nvim-treesitter` is declared in `lua/plugins/treesitter.lua`.
It uses the `main` branch with an exact revision in `lazy-lock.json`.
The plugin loads at startup, and `:TSUpdate` is its build step.

On detecting the filetype of a normal file buffer,
`lua/functions/treesitter.lua` enables highlighting and asynchronously
installs a missing parser from the plugin catalogue. Neovim and the plugin
map filetypes to languages, such as `sh` → `bash`. Only the needed language
and its required dependencies are downloaded. Buffers using the same
language share one installation. Highlighting attaches after installation
without reopening the file.

Built-in syntax highlighting remains a fallback. Unknown filetypes and
special buffers do not trigger downloads. A failure produces a warning and
no further automatic attempt for that language during the session. Folding
and the color scheme are unchanged.

Vue, TSX, and JSX indentation uses installed `nvim-treesitter`: Neovim's
standard Vue and TSX scripts use HTML and TypeScript rules that mishandle
nested components. `after/indent/` files call
`functions.treesitter.configure_indentation()` after the standard scripts.
If the parser or indent queries are unavailable, standard rules remain; a
successful background installation enables the indent handler in waiting
buffers. Without `.editorconfig`, the step is two spaces. Project
`indent_size`, `indent_style`, and `tab_width` take precedence. `Enter`, `o`,
`O`, JSX fragments, attribute expressions, and Vue `script`/`style` blocks
were checked. Nested languages need their own parsers, such as `typescript`
and `css`. The plugin's developers mark this indentation mechanism
experimental; checks do not cover arbitrary damaged markup.

Requirements are `tree-sitter-cli` version `0.26.1` or newer, a C compiler,
`curl`, and `tar`. The development environment has stable
`tree-sitter-cli 0.27.0` installed with Homebrew. Parsers and queries are
stored under `stdpath("data") .. "/site"`. Additional languages embedded
in a multilingual document are not automatically detected for installation;
use `:TSInstall` when needed.
