# Operations

The configuration has been tested only on macOS 27.0 (build 26A428) with
Neovim 0.12.5. Other operating systems have not been tested.

## First launch after cloning

1. Install Neovim `0.12.5` or a compatible newer stable release.
2. Ensure Git `2.19` or newer is available. Tree-sitter also needs a C
   compiler, `curl`, `tar`, and `tree-sitter-cli >= 0.26.1`. On macOS, install
   the CLI with `brew install tree-sitter-cli`; Apple developer tools provide
   the compiler. Install ripgrep (`rg`) to use Telescope project text search.
3. Clone into Neovim's configuration directory:
   `git clone https://github.com/hardcodd/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"`.
4. Start `nvim` with network access.

`lazy.nvim`, Telescope, `plenary.nvim`, `nvim-treesitter`, `nvim-autopairs`,
and `paired-tags.nvim` download automatically. Opening a supported file
downloads and builds a missing parser in the background, which needs network
access. After installation, run `:checkhealth telescope` and
`:checkhealth nvim-treesitter`.

## Verification

Use `Space f f` to find files and `Space f g` to search text. Text search
requires ripgrep (`rg`). Run these headless checks from the configuration
root:

```sh
test_root=$(mktemp -d)
XDG_DATA_HOME="$test_root/data" XDG_STATE_HOME="$test_root/state" XDG_CACHE_HOME="$test_root/cache" nvim --headless -u NONE -i NONE -n -l tests/init_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/vault_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/treesitter_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/explorer_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/keymaps_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/insert_navigation_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/telescope_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/editorconfig_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/indentation_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/html_indent_spec.lua
nvim --headless -i NONE -n '+lua local ok, err = pcall(dofile, "tests/paired_plugin_integration_spec.lua"); if not ok then print(err); vim.cmd("cquit") end' +qa!
nvim --headless -i NONE -n '+lua local ok, err = pcall(dofile, "tests/paired_editing_spec.lua"); if not ok then print(err); vim.cmd("cquit") end' +qa!
nvim --headless -i NONE -n '+lua local ok, err = pcall(dofile, "tests/tag_scenarios_spec.lua"); if not ok then print(err); vim.cmd("cquit") end' +qa!
nvim --headless -u NONE -i NONE -n -l tests/autocmds_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/indent_guides_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/theme_spec.lua
nvim --headless -u NONE -i NONE -n -l tests/statusline_spec.lua
nvim --headless -i NONE -n '+luafile tests/theme_integration.lua' +qa
nvim --headless -i NONE -n '+lua local ok, err = pcall(dofile, "tests/statusline_integration.lua"); if not ok then print(err); vim.cmd("cquit") end' +qa!
```

The first test needs isolated data because it creates a stub `lazy.nvim`
there. Tree-sitter tests model successful and failed installation, concurrent
buffers, filetype changes, and a buffer closing during installation. Mapping
tests cover function and command actions, modes, buffer scope, option
overrides, and invalid arguments. The configuration check also confirms that
custom function definitions live under `lua/functions/`.
`tests/insert_navigation_spec.lua` checks all eight Insert-mode cursor
movements without unintended text changes or leaving Insert mode. Check
separate `Ctrl+Shift` transmission manually in your terminal. Autocommand
tests cover events, reconfiguration of groups, registration options, and
invalid arguments.

The Telescope test requires installed Telescope and `plenary.nvim`. It checks
mappings in both modes, result selection, preservation of default keys,
safe preview scrolling when no preview exists, and the actual two-line or
two-column step. It covers Lua and other tab widths, loaded-file settings,
variable tab width, and missing metadata. Also check terminal transmission
of `Ctrl+Shift` manually in a picker with an open preview.

In a write-restricted environment, set temporary `XDG_STATE_HOME` and
`XDG_CACHE_HOME` for integration checks too: Neovim and Catppuccin write a
log and theme cache there.

Catppuccin and lualine also install automatically at first launch. The theme
integration check loads the real configuration and needs installed plugins;
it may download them if absent. Manual system appearance verification is
described in [[Appearance]].

Parser installation errors are available in `:TSLog`. To retry, run
`:TSInstall python` with the required language, wait for completion, and
reopen the buffer. Use `:TSInstall! python` to repair an incomplete install.
Installed parsers work offline; `:Inspect` checks highlighting at the cursor.

## System clipboard

`init.lua` sets `clipboard=unnamedplus`: ordinary `y`/`yy` copies to the
system clipboard, and `p`/`P` pastes from it. Delete (`d`) and change (`c`)
also replace the clipboard with the removed text. Use `"_dd` to delete a
line without replacing the clipboard; explicit named registers stay separate.

Neovim selects its clipboard provider automatically. On macOS it uses the
built-in `pbcopy` and `pbpaste`, with no additional plugin. Other systems need
an available clipboard provider; inspect it with `:checkhealth vim.provider`.
Restart Neovim after this configuration change, or run
`:set clipboard=unnamedplus` in an existing session. Check copying with `yy`
into another application and using `p` to paste text copied there.

`tests/init_spec.lua` checks copying, pasting, deletion, and explicit-register
bypass using a stub provider, without changing the real system clipboard.

## Closing

`Space q` starts a confirmed Neovim quit. `Space x` removes only the current
buffer, leaving Neovim open even when no other file remains. With unsaved
changes, either action offers save, discard, or cancel.

## Project settings

Built-in `.editorconfig` support is enabled for normal files. Project rules
take precedence over built-in indentation for every filetype. Supported
Neovim settings include indentation, encoding, line endings, and save-time
handling. Inspect effective indentation with
`:setlocal tabstop? shiftwidth? softtabstop? expandtab?`. Telescope reads tab
width from the same settings without formatting preview text; see
[[Plugins#Telescope]].

`tests/indentation_spec.lua` checks space insertion, common filetype defaults,
and `.editorconfig` precedence. `tests/editorconfig_spec.lua` compares tab
width in normal buffers and previews, covering nested rules, `root`,
sections, `unset`, explicit `tab_width`, invalid values, and rereading
changed settings.

`tests/html_indent_spec.lua` checks indentation after an opener, one `Enter`
between paired tags, nesting, `htmldjango`, and project indentation. It
loads installed `paired-tags.nvim` from Neovim's data directory. To check an
unpublished local plugin version, set `PAIRED_TAGS_SOURCE` to its directory.

`tests/component_indent_spec.lua` checks 35 real-input scenarios for Vue,
TSX, and JSX: `Enter`, `o`, `O`, absent `.editorconfig`, project spaces and
tabs, fragments, and embedded languages. Installed `vue`, `tsx`,
`javascript`, `typescript`, and `css` parsers are required. Run it with the
full configuration:

```sh
rtk nvim --headless -i NONE -n '+lua local ok, err = pcall(dofile, "tests/component_indent_spec.lua"); if not ok then print(err); vim.cmd("cquit") end' '+qa!'
```

`tests/paired_editing_spec.lua` runs with the real configuration and plugins.
It checks symbol pairs and tag closing and renaming in XML, JSX/TSX, Vue,
Svelte, Django HTML, and HTML embedded in Markdown. These languages need
installed Tree-sitter parsers; a normal first launch installs them as files
open. Also check `<div>` insertion and renaming both names interactively:
part of the headless test calls the tag handler directly after simulated
input. The test also checks a fast `Enter` after `>` and parses
`tests/fixtures/paired_editing_landing.html`.
`tests/paired_plugin_integration_spec.lua` checks the GitHub plugin load,
external module, mappings, and autocommands. The plugin's standalone tests
and `SPECS.md` are in its own repository. The fixture was typed in live
Neovim and contains two sections, nested `article`, `aside`, `details`,
lists, inline tags, attributes, and void elements. For a manual check, open
it, create a nested tag inside an existing tag, then rename its opener and
closer in turn. A separate regression check types an unfinished `<address`
before `</p>`: the `</p>` and ancestor closers must stay unchanged, and the
tag gets `</address>` after its own `>`.

`tests/tag_scenarios_spec.lua` covers JSX/TSX components and fragments,
nested same-name tags, XML, HTML with optional `li`, `p`, `option`, table-row
and table-cell closers, and literal Markdown code. A `>` inside an existing
attribute must not insert a closer inside quotes. Editing is skipped when
the required parser is absent; `tests/paired_editing_spec.lua` checks that
case separately. It also checks renaming an attributed `script` closer:
the partner opener changes, while closer-like text in a script string or
comment does not change the opener.

`tests/tag_bug_regressions_spec.lua` reads 51 cases from
`tests/tag_bug_cases.json`. It opens temporary files and sends real keys
through `nvim_input`, covering interrupted input, paste, renaming from both
sides, and HTML `Enter`; it does not call the tag handler directly. Installed
parsers and the normal Neovim configuration are required:

```sh
rtk env XDG_STATE_HOME=/private/tmp/nvim-tag-test-state XDG_CACHE_HOME=/private/tmp/nvim-tag-test-cache nvim --headless -i NONE -n '+luafile tests/tag_bug_regressions_spec.lua'
```

`TAG_REGRESSION_CASE` selects a JSON case ID. `TAG_REGRESSION_DELAY` sets
the delay between actions in milliseconds; the default is 50. Also use
`TAG_REGRESSION_DELAY=120` to check sensitivity to timing.

`tests/tag_bug_report_2_spec.lua` reads 31 confirmed second-audit cases
from `tests/tag_bug_report_2_cases.json` and adds four edge cases. It checks
four groups: streamed paste with snapshots after incomplete chunks, literal
text, separate `diw` and Insert in XML, and movement between names in one
Insert session. Installed parsers and the normal configuration are required:

```sh
rtk env XDG_STATE_HOME=/private/tmp/nvim-b2-state XDG_CACHE_HOME=/private/tmp/nvim-b2-cache nvim --headless -i NONE -n '+luafile tests/tag_bug_report_2_spec.lua'
```

`TAG_B2_CASE` selects an ID, and `TAG_B2_DELAY` sets the delay in
milliseconds; the default is 40. The complete final buffer is compared.
For the streamed-paste undo case, the buffer after `u` is compared too.

`tests/tag_bug_report_3_spec.lua` checks 57 third-audit cases from
`tests/tag_bug_report_3_cases.json` plus five edge cases. They exercise
outer HTML tag renaming, attributed-name replacement in JSX/XML/Vue, a real
`textarea` closer, multiline Vue interpolation, and whitespace or a newline
before `>` in XML. Each case compares the complete buffer; source files are
temporary. Run with the full configuration:

```sh
rtk env XDG_STATE_HOME=/private/tmp/nvim-b3-state XDG_CACHE_HOME=/private/tmp/nvim-b3-cache nvim --headless -i NONE -n '+luafile tests/tag_bug_report_3_spec.lua'
```

`TAG_B3_CASE` selects an ID and `TAG_B3_DELAY` sets milliseconds between
actions; the default is 40. Parsers for the tested languages must be
installed.

`tests/tag_bug_report_4_spec.lua` checks 184 selected fourth-audit cases and
four additional controls from `tests/tag_bug_report_4_cases.json`. They cover
literal fragments in Vue interpolation, XML processing instructions and
`ENTITY` values, Django comments, multiline CSS inside `style`, and real
tags beside those fragments. Cases where only Vue's standard indentation
differed were excluded; one auto-close case accounts for that indentation
in the expected buffer. Run with the full configuration:

```sh
rtk env XDG_STATE_HOME=/private/tmp/nvim-b4-state XDG_CACHE_HOME=/private/tmp/nvim-b4-cache nvim --headless -i NONE -n '+luafile tests/tag_bug_report_4_spec.lua'
```

`TAG_B4_CASE` selects an ID and `TAG_B4_DELAY` sets milliseconds between
actions; the default is 40. The test compares the complete buffer and needs
parsers for the tested languages.

## Updating

Use `:Lazy` to inspect and update plugins. After an approved update, check
the configuration and include the changed `lazy-lock.json` in the same
commit. When changing a plugin, key mapping, architecture, or installation
procedure, update the corresponding knowledge-base pages.

Related pages: [[Architecture]], [[Plugins]], [[Keymaps]].
