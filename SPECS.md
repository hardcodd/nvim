# Neovim Base Configuration Specification

## Objective

Provide a small, portable Neovim configuration compatible with Neovim 0.12.5.

## Expected behavior

- Use Space as the leader key and retain the standard key behavior wherever
  possible.
- Enable practical editing, search, UI, split-navigation, persistence, and
  completion defaults.
- Display long lines without soft wrapping by default, including in newly
  opened editing windows. Keep the file text unchanged and allow a window-local
  `wrap` override when needed.
- Bootstrap `lazy.nvim` automatically when it is missing, so a fresh clone
  installs the declared plugins on the first Neovim launch.
- Configure Telescope with its required `plenary.nvim` dependency and expose
  file, text, buffer, and help search through leader mappings.
- In Telescope Insert and Normal modes, Ctrl+J/K select the next/previous
  result, Ctrl+Shift+J/K scroll the preview down/up, and Ctrl+Shift+H/L scroll
  the preview left/right. Keep these mappings
  local to Telescope and preserve its other defaults. Shift combinations
  require a terminal that transmits distinct modified keys.
- Scroll Telescope previews by two lines vertically or two columns horizontally.
- Match preview tab rendering to the loaded source buffer's `tabstop` and
  `vartabstop`. For unopened files with a known filetype, use the same width
  policy as an ordinary buffer; without a filetype, use global defaults.
  Apply matching `.editorconfig` tab widths last, including for
  unopened files. Resolve parent sections, nested overrides, `root`, `unset`,
  `indent_size`, and explicit `tab_width` with Neovim-compatible semantics.
  Do not change source contents, source options, or preview guides.
- Explicitly enable Neovim's built-in EditorConfig support for ordinary file
  buffers. Project properties apply after filetype defaults, including Lua.
  Preview only applies display-related tab width; it must not install save
  hooks or reformat text. Use no additional dependency.
- Use `<leader>q` to close Neovim and `<leader>x` to close only the current
  buffer. Both actions must request confirmation for unsaved changes.
- In Normal mode, `<leader>w` writes changes in the current file using native
  `:write` behavior, without affecting other buffers or forcing a write when
  Neovim rejects it.
- Keep Neovim open with a reusable empty buffer when `<leader>x` closes the
  last listed buffer.
- Use `jk` in Insert mode to return to Normal mode.
- In Insert mode, Ctrl+H/J/K/L move the cursor left/down/up/right by one
  character or line without editing text. Ctrl+Shift+H/L move one word
  backward/forward; Ctrl+Shift+J/K move down/up by one line. These mappings
  intentionally replace Insert-mode Ctrl+H deletion and Ctrl+J newline input.
  Distinct Ctrl+Shift input depends on terminal support. Telescope-local
  mappings retain their selection and preview actions.
- In Normal mode, `<leader>e` opens the built-in netrw browser for the
  current file's directory (the working directory for an unnamed buffer),
  replacing the previous diagnostic popup mapping without adding dependencies.
  Opening the browser must preserve unsaved buffer contents.
- Reuse an existing local netrw browser: focus its window (including another
  tab), or show its hidden loaded buffer. Preserve its directory and cursor.
  Create a browser only when none exists; repeated presses must not duplicate it.
- Use native diagnostics mappings that remain harmless when no language server
  is attached.
- Highlight yanked text and restore the last editing position when reopening a
  normal file.
- Default to four-space indentation (`shiftwidth=4`, `tabstop=4`,
  `softtabstop=-1`, `expandtab=true`) for unspecified and common four-space
  filetypes, including Python, C/C++, C#, Java, Rust, and shell scripts.
- Use two spaces for HTML, Django HTML (`htmldjango`), CSS, SCSS, JavaScript,
  TypeScript, JSX/TSX, JSON, JSONC, YAML, XML, Vue, Svelte, Markdown, TOML,
  and Lua. Set `shiftwidth` and `tabstop` to 2, `softtabstop` to -1, and
  `expandtab` to true.
- Enable Neovim's native filetype indent scripts. In HTML and Django HTML,
  Enter after an opening tag must indent the following content by the effective
  `shiftwidth`. One Enter between adjacent matching opening and closing tags,
  such as `<div>|</div>`, must create an indented content line and put the
  closing tag at the opener's level. Other Enter cases keep native behavior.
  The pair behavior must honor project `.editorconfig` indentation settings,
  use no new dependency, and leave non-HTML filetypes unaffected.
- Preserve language-required literal tabs for Go (`shiftwidth=8`, `tabstop=8`,
  `softtabstop=0`, `expandtab=false`) and Makefiles (`shiftwidth=8`,
  `tabstop=8`, `softtabstop=0`, `expandtab=false`).
- Apply filetype rules to buffers open at startup and those opened later, after
  built-in filetype defaults. Project `.editorconfig` settings take precedence.
  Do not rewrite existing file contents when setting indentation defaults.
- Store configuration-owned key mappings in `lua/keymaps.lua`, organized into
  clearly labeled functional blocks. The paired-tag plugin owns its `>` and
  `<CR>` mappings. Keep plugin declarations under `lua/plugins/`.
- Keep all custom production function definitions under `lua/functions/`, in
  modules grouped by responsibility. Configuration files only wire functions
  and declare settings; tests retain their own helpers.
- Declare mappings with `map.n(keys, action, description, options?)` and
  equivalent mode helpers, or `map.set(mode_or_modes, ...)` for multiple modes.
  Actions are native key sequences or function references. `map.cmd(command)`
  explicitly converts an Ex command to a command mapping.
- Require nonblank keys and descriptions; use silent, nonrecursive mappings by
  default. Pass native options through without mutating caller-owned tables;
  explicit options may override defaults. Preserve existing keys and actions.
- Keep the base editor autocommands in `lua/autocmds.lua`. Register
  configuration-owned autocommands and groups through `functions.autocmds`.
  The paired-tag plugin owns its callbacks and registers them internally.
  Preserve the events, timing, and effects of unrelated handlers.
- Use `auto.group(name)` to create or replace a named group, and
  `auto.set(events, callback, description, options?)` to register one callback
  for one or more events. Require nonblank group names and descriptions, and a
  callable callback. Pass native autocommand options through without mutating
  the caller's table; the explicit callback and description take precedence.
- Maintain an Obsidian knowledge base in `Neovim Knowlage/` with a linked home
  page, architecture overview, plugin inventory, keymap reference, and
  operational notes for this configuration.

## Paired editing

- On Insert input in normal editing buffers, automatically insert the matching
  `)`, `]`, `}`, single quote, double quote, or backtick after an opening
  character. Keep the cursor between the pair, skip an existing closing
  character, and delete an empty pair together with Backspace. Preserve
  ordinary text entry and existing completion behavior.
- Use the published `nvim-autopairs` `0.10.0` release, pinned in the plugin
  declaration and `lazy-lock.json`. Preserve the current `<CR>` mapping and
  its HTML/Django HTML indentation behavior when configuring the plugin.
- In HTML, XML, Django HTML, JSX/TSX, Vue, Svelte, and embedded HTML in
  Markdown, typing `>` after an opening tag adds its closing tag, and editing
  either tag name updates the matching tag name. Do not add a second closing
  tag when one already exists, or one for void or self-closing elements.
- Renaming a closing tag must update its matching opening tag even when that
  opener has attributes, including multiline attributes and nested content.
  Preserve attribute text and other tag names exactly. This includes HTML
  raw-text elements such as `script`, whose edited closer may temporarily be
  parsed as text. Leave closing-tag-like text inside raw-text content alone
  when an explicit original closer still exists or the text is in a quoted
  string or comment.
- Creating a new child tag must never rename or consume a closing tag of its
  parent or another existing element, including while the new tag name is
  incomplete. Only an edit to the name of an existing paired tag may rename
  that tag's mate.
- While a new opening tag lacks its own unquoted `>`, a later `>` from an
  existing closing tag must not make it appear complete. Typing a partial
  inline or block tag before `</p>` must preserve `</p>` and every ancestor
  closer, even while the HTML parser recovers from temporarily invalid markup.
  Quoted attribute text and JSX expressions may contain angle brackets without
  ending the surrounding tag. Typing `>` inside a quoted attribute of an
  already complete opening tag must not insert a closer at that position.
- In JSX/TSX, preserve self-closing intrinsic and custom components such as
  `<MenuComponent />`, and close ordinary capitalized, member-qualified, and
  namespaced component tags with the exact original name, including valid `$`
  identifiers. Support fragment pairs `<>...</>` and JSX expressions inside
  attributes. Leave comparisons, generic type parameters, strings, and
  comments unchanged.
- Preserve case and UTF-8 names for XML tags when pairing and renaming.
- In HTML and its template languages, inserting a same-name child before its
  parent's existing closer must create a separate child closer. Keep HTML void
  elements, custom elements, foreign SVG/MathML markup, raw text, quoted
  attributes, and already paired or partially edited tags safe. When pairing
  is ambiguous, leave other existing tags untouched.
- Pair renames in valid HTML that omits optional child end tags, including
  consecutive `li` and `p` elements, options, and common table rows and cells,
  without changing the omitted child tags.
- Treat inline and fenced Markdown code as literal text even when its info
  string names an injected markup language.
- Closing a new tag must finish before a following Enter is applied, including
  when those keystrokes arrive without a pause.
- Load tag handling and the HTML/Django HTML Enter behavior from the public
  `hardcodd/paired-tags.nvim` repository through `lazy.nvim`. Do not retain
  duplicate implementations in `lua/functions/`. Tag features require a
  working parser for the current language. Handle incomplete edits and
  embedded languages without changing text outside the matched tag name.
- Do not change unrelated editor keymaps or install parsers for unrelated
  languages just to enable tag handling.
- Exercise HTML tag editing by typing a small, valid, standalone landing page
  in a live Neovim session. The page has two content sections and uses nested
  inline elements, quoted attributes, and void elements. Preserve every
  enclosing tag while creating or editing its descendants. Keep the example
  as a pure HTML fixture without CSS, JavaScript, or external resources.
- Treat HTML void names case-insensitively in HTML. In JSX/TSX, Vue, and
  Svelte, preserve PascalCase components named Input, Link, Meta, Source, or
  BR as paired components while keeping lowercase intrinsic void tags void.
- In TSX, close and rename generic components without changing type arguments,
  including nested generic arguments and JSX expression props with comments,
  regular expressions, and template strings.
- During renames, preserve the original pair even when the edited name matches
  an ancestor or sibling, the parser temporarily recovers invalid markup, or
  HTML changes its implicit end-tag rules. Never modify a different element,
  type argument, interpolation string, or raw-text content to satisfy a rename.
- Completing a new child tag must create its own closer after an Insert session
  ends, after paste, and when editing a partially written file, while leaving
  the parent's closer intact.
- Synchronize closing-side renames in XML and Svelte components through actual
  editor input events, including nested elements and multiline attributes.
- Parse HTML/XML quoted attribute delimiters without treating a preceding
  backslash as an escape. Parse braces only in JSX expressions, and distinguish
  an unquoted HTML attribute value ending in `/` from a self-closing delimiter.
- Treat HTML raw-text and escapable-raw-text elements, including script, style,
  textarea, title, xmp, iframe, noembed, and noframes, as text containers for
  autoclose and pair search. Protect JSX/Vue expressions, strings, comments,
  and JavaScript regular expressions from delimiter scanning.
- An HTML/Django HTML Enter between matching tags must retain its two-line
  split and indentation when the opening tag has quoted `<` or `>` characters.
- Verify each of these behaviors with real Neovim input, complete-buffer
  comparisons, and both focused regressions and the existing broader scenarios.
- During one streamed `nvim_paste` transaction, including pauses between
  chunks, do not insert a closing tag or rename a mate from incomplete pasted
  content. After the final chunk, preserve a complete pasted fragment without
  duplicate closers. Cover chunk boundaries after `>`, inside a name and an
  attribute, nested markup, cancellation, and ordinary single-call paste.
- Treat tag-like text in Markdown inline/fenced code, HTML text-only elements,
  and Vue interpolation strings as literal while editing either apparent name,
  including a replacement supplied by paste. Never change another literal
  occurrence through a remembered pair.
- In XML, preserve the original pair across `diw` on a closing name followed
  by a separate Insert session, including typed and pasted replacements and
  neighboring elements. Captured pair positions must remain valid while the
  source name is temporarily empty.
- In XML Insert mode, moving to a different opening or closing name must
  capture that pair before its first edit. Cover adjacent and nested elements,
  appending a name, replacing a name, and successive pair edits in one Insert
  session without changing unrelated tags.
- A complete rename of an attributed outer HTML tag must update its original
  closer, leaving all nested closers unchanged, including when an inner script
  contains a regular expression with a quote. Preserve literal backslashes in
  HTML attribute values; do not interpret them as quote escapes.
- Replacing a whole opening name must retain its closer when the opener has
  attributes in JSX, XML, or Vue script/style. Cover `ciw`, separate deletion
  and insertion, typed input, ordinary paste, and streamed paste. Keep TSX and
  attribute-free equivalents as controls.
- Renaming the real closing tag of an HTML text-only element must update its
  opener even when the element sits inside a parent and contains apparent tags
  as literal text. Apparent tags in that content remain unchanged.
- Treat quoted text inside multiline Vue interpolations as literal, including
  both edit directions, pasted replacements, template strings, and expressions
  spanning lines. Only the edited occurrence may change.
- Preserve a captured XML pair while its closing name is empty before spaces
  or a line break preceding `>`. Cover `diw` followed by a separate Insert
  session, `ciw`, typed and pasted replacements, streamed paste, opening-tag
  attributes, and the cursor position required at end of line.
- In Vue, apparent tags inside interpolation strings remain literal when a
  string continues across lines or when a preceding JavaScript comment or
  regular expression contains a quote. Editing either apparent name or typing
  an apparent opening tag changes only the user's text. A completed HTML
  comment containing `{{` and quotes must not suppress editing or autoclosing
  real Vue tags that follow it on the same line.
- In XML, processing instructions and DTD entity values are literal contexts:
  editing one apparent tag name or typing an apparent opening tag there must
  not change or create another tag. Normal XML elements outside those contexts
  retain pair editing and autoclosing.
- In Django HTML, apparent tags inside short `{# ... #}` and block
  `{% comment %} ... {% endcomment %}` comments remain literal on one or
  multiple lines; real tags around those comments still pair normally.
- In HTML, apparent tags in a CSS string inside a multiline `style` element
  remain literal, as they do in an inline `style` element. Cover typed and
  pasted renames without changing a second apparent tag.
- Verify these boundaries with full-buffer assertions through real Neovim
  input, including both rename directions, paste and relevant nearby controls.

### Vue and JSX indentation

- New lines created with Enter, `o`, and `O` in Vue, TSX, and JSX must follow
  syntax nesting, including custom components, fragments, and expression props.
- Use the existing Tree-sitter indentation engine for these filetypes when
  their parser and indent queries are available; retain native indentation
  otherwise. Other filetypes retain their current indentation engine.
- Preserve two-space defaults and honor effective EditorConfig space/tab widths.
  Test both defaults and project overrides with actual editor input.
- Preserve embedded Vue script/style indentation and existing tag pairing.

## Appearance

- In normal editing buffers, show each leading tab with a narrow vertical
  guide. For leading spaces before code, show one guide at the start of each
  complete effective `shiftwidth` level and dots only for an incomplete final
  level. With width two, two spaces render as `│ `, three as `│ ·`, and four
  as `│ │ `. Ignore whitespace-only lines, inline whitespace, and special
  buffers. Follow buffer, window, and indentation-width changes without
  changing file contents.
- Continue highlighting the first transition between tabs and spaces in
  leading indentation. Use Catppuccin's quieter `surface1` foreground for
  vertical guides on tabs and complete space levels, `overlay0` for dots on
  incomplete levels, and `surface0` background for mixed-indent warnings in
  both light and dark palettes. Add no dependency or persistent file marks.
- Install stable Catppuccin v2.0.0 automatically through lazy.nvim, locked to
  its release commit. Load it before other start plugins with priority 1000.
- Use Latte for light appearance and Mocha for dark appearance, with automatic
  integrations for supported lazy.nvim plugins and native Tree-sitter/LSP colors.
- On macOS, read global system preferences asynchronously at startup, on focus,
  and every three seconds. Follow system appearance without restarting Neovim.
- Missing AppleInterfaceStyle in a successful preferences read means light.
  Failed or malformed reads preserve the current background; overlapping reads
  are skipped and each process has a two-second timeout.
- Repeated setup and shutdown must release timers and ignore stale callbacks.
  Other systems retain Neovim's background selection without macOS commands.
- Test both transitions, failure recovery, repeated setup, shutdown, and the
  real theme's Tree-sitter, diagnostic, and Telescope highlight groups.

## Statusline

- Install lualine.nvim through the existing first-launch bootstrap, locking its
  upstream revision without upgrading other dependencies or adding icon plugins.
- Use one global statusline, Catppuccin colors that follow background changes,
  diagonal internal joins, straight outer edges, a colored mode label, and no
  Nerd Font requirement (use standard Unicode geometric and diagonal symbols).
- Show mode, Git branch and changed-line counts, project-relative filename
  (working-directory-relative outside Git), modified/readonly indicators,
  error/warning counts, filetype, and line/column. Hide empty contextual data.
- Show search match counts during highlighted searches, selection size in
  Visual mode, and LSP status when a client is attached.
- Show the file encoding and BOM marker on the right at 60 columns or more;
  use Neovim's encoding when fileencoding is empty. Never change file encoding.
- At less than 100 columns hide diff and LSP; below 80 also hide branch and
  filetype; below 60 shorten mode and filename and hide contextual counters.
  Keep filename, modified/readonly markers, diagnostics, and position useful.
- Verify real statusline rendering with both palettes, narrow screens, split
  windows, unnamed/readonly/modified buffers, diagnostics, and contextual data.

## General implementation constraints

- Do not change editor behavior outside this configuration directory.
- Use English identifiers and comments.
- Do not add optional native Telescope extensions. The approved Tree-sitter
  integration requires tree-sitter-cli and the compilation tools listed below.
- Keep the README and knowledge base in English, retaining identifiers,
  commands, file paths, and plugin names exactly as used by the configuration.
- Exclude operating-system metadata, Neovim logs, the obsolete root Obsidian
  settings directory, and the machine-specific Obsidian workspace layout from
  version control.

## Acceptance criteria

- Enable native syntax highlighting as a fallback and Tree-sitter highlighting
  for supported filetypes in normal file buffers.
- Install missing language parsers asynchronously on FileType, using Neovim's
  filetype-to-language mapping. Do not download the entire parser catalogue.
- Share a pending installation between buffers and attach highlighting after
  installation only to still-valid buffers with the same language.
- Unsupported filetypes and special buffers must not trigger downloads.
- Failed downloads must preserve editing and native syntax highlighting, warn
  the user, and avoid repeated automatic attempts during the same session.
- Use nvim-treesitter with its revision locked and tree-sitter-cli (stable),
  a C compiler, curl and tar. Preserve folding behavior. Component indentation
  is enabled separately as specified above.

- Neovim can start headlessly with this configuration without Lua errors.
- The initial editing window and a new editing window use `nowrap` by default;
  `wrap` can still be enabled locally for a window.
- Indentation tests cover global defaults, the listed filetype groups, startup
  and later buffers, literal tabs in Go/Make, and `.editorconfig` overrides.
  HTML tests cover nested lines, adjacent tag pairs, nonmatching tags, Django
  HTML, non-HTML input, and project indent overrides.
- Rendering tests cover guide and dot placement for two- and four-column
  indentation, `tabstop` fallback, leading tabs, mixed tabs and spaces, buffer
  and window switches, edits, and special buffers. Both palettes use muted
  guide and mixed-indent warning colors.
- The asserted editor options, mappings, and autocommands are present.
- Headless editing tests verify brackets and quotes, skip and Backspace
  behavior, and that HTML `<CR>` indentation still works with paired editing.
- Headless editing tests verify tag insertion across the listed filetypes and
  renaming from both the opening and closing tag in representative filetypes,
  plus nested tags, new child tags inside existing elements, void/self-closing
  tags, existing closing tags, partial tags before parent closers, immediate
  Enter, and ordinary text outside tags.
- Scenario tests cover JSX/TSX components, self-closing tags, fragments,
  expressions, generics, and same-name nesting, plus HTML parser recovery and
  embedded/template languages. Validate real Insert-mode key sequences, not
  only direct handler calls, before treating tag editing as ready for daily use.
- Inspect the live-typed landing page for balanced tags, two content sections,
  intact nested inline markup, and absence of Tree-sitter parse errors. Add
  focused automated regressions for any tag-editor defects it exposes.
- `init.lua` loads the dedicated keymaps module, and no key mappings are
  declared outside `lua/keymaps.lua`. Only `lua/functions/keymaps.lua` invokes
  the native `vim.keymap.set` registration API.
- Mapping tests cover callable actions, key sequences, Ex commands, multiple
  modes, buffer scope, option overrides, invalid inputs, and unchanged options.
- Autocommand tests cover event dispatch, multiple events, groups, group
  replacement, native options, invalid inputs, and unchanged options.
- A missing `lazy.nvim` installation is cloned into Neovim's data directory
  and loaded before plugin setup.
- Telescope and `plenary.nvim` are declared in a dedicated plugin module.
- Verify Telescope selection and preview actions in both modes, retaining
  default mappings and leaving ordinary editing buffers unaffected.
- Test preview scroll distance and tab widths for Lua, other filetypes,
  loaded-buffer overrides, variable tab widths, and missing preview metadata.
- Compare preview widths with native EditorConfig in real editing buffers;
  cover nested and root configurations, glob sections, unset and malformed
  values, absent configuration, and changes to configuration between previews.
- Telescope mappings exist for `<leader>ff`, `<leader>fg`, `<leader>fb`, and
  `<leader>fh`.
- `<leader>q` uses a confirmed `:qall` command, and `<leader>x` uses a
  confirmed `:bdelete` command.
- `<leader>w` saves changed buffer contents to the current file and clears its
  modified state after a successful write.
- Closing the final buffer leaves a valid current buffer and does not exit
  Neovim.
- `jk` is mapped in Insert mode to leave Insert mode.
- Insert-mode navigation tests verify all eight mappings move the cursor as
  specified without unintended text changes or leaving Insert mode.
- `Neovim Knowlage/` is the Obsidian vault and contains `.obsidian/app.json`.
- The repository landing page gives the clone location, first-launch
  requirements, and a link to the detailed operational guide.
- `.gitignore` excludes local-only files without excluding the vault notes or
  its shareable Obsidian settings.
