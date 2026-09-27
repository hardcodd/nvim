# Key mappings

The leader is `Space`. Mappings owned by this configuration live in
`lua/keymaps.lua`; `paired-tags.nvim` maps `>` and `Enter` for tags when Lazy
loads it. Use `functions.keymaps` to add mappings; see [[Functions]] for
examples and supported options.

## Search

| Key | Action |
| --- | --- |
| `Esc` | Clear search-match highlighting. |

## Modes

| Key | Action |
| --- | --- |
| `j k` in Insert mode | Return to Normal mode. |
| `Ctrl+H/J/K/L` in Insert mode | Move left one character / down one line / up one line / right one character. |
| `Ctrl+Shift+H/L` in Insert mode | Move to the previous / next word. |
| `Ctrl+Shift+J/K` in Insert mode | Move down / up one line. |

`Ctrl+H` replaces the usual character deletion, and `Ctrl+J` replaces newline
insertion. In terminals that send `Backspace` as `Ctrl+H`, Backspace also
becomes cursor movement. The terminal must transmit Shift separately for the
`Ctrl+Shift` bindings; otherwise they may collide with the unshifted bindings.
Telescope's local mappings apply inside its picker.

## HTML

| Key | Action |
| --- | --- |
| `Enter` in Insert mode between `<div>` and `</div>` | Create an indented content line and move the closer below it. Applies to adjacent matching tags in HTML and `htmldjango`; otherwise Enter retains its normal behavior. |
| `>` in Insert mode | Complete an opener immediately in a supported language so the next Enter sees its closer. Inserts a normal `>` in other buffers. |

`nvim-autopairs` inserts matching brackets and quotes. Typing a closer moves
past an existing pair, and `Backspace` inside an empty pair removes both
characters. Tags need no separate user mapping; see
[[Plugins#Paired symbols and tags]] for insertion and renaming behavior.

## Diagnostics

| Key | Action |
| --- | --- |
| `[d` | Go to the previous diagnostic. |
| `]d` | Go to the next diagnostic. |

## File browser

| Key | Action |
| --- | --- |
| `Space e` in Normal mode | Focus an open `netrw` browser, even in another tab. If none exists, open the current file's directory; for an unnamed buffer, open the working directory. |

In the browser, `Enter` opens a file or directory and `-` moves up one level.
Unsaved changes to the current file remain in its buffer. A hidden browser
buffer is reused with its directory preserved. Pressing the mapping again
inside the browser does nothing. If the current file is modified and `hidden`
is off, a hidden browser opens in a split. `Space e` previously showed
diagnostics; it now opens the file browser.

## Buffer and session

| Key | Action |
| --- | --- |
| `Space w` in Normal mode | Save the current file with `:write`. On failure, Neovim reports the error and leaves the buffer modified. |
| `Space q` | Quit Neovim. Unsaved changes prompt to save, discard, or cancel. |
| `Space x` | Close only the current file. Unsaved changes prompt to save, discard, or cancel. Closing the last file leaves Neovim open with an empty buffer. |

## Telescope

| Key | Action |
| --- | --- |
| `Space f f` | Find a file. |
| `Space f g` | Search project text with ripgrep. |
| `Space f b` | Find an open buffer. |
| `Space f h` | Find a Neovim help page. |

Inside Telescope, in both Insert and Normal mode:

| Key | Action |
| --- | --- |
| `Ctrl+j` / `Ctrl+k` | Select the next / previous result. |
| `Ctrl+Shift+j` / `Ctrl+Shift+k` | Scroll the preview down / up. |
| `Ctrl+Shift+h` / `Ctrl+Shift+l` | Scroll the preview left / right. |

Holding a key repeats its action through keyboard auto-repeat. Each preview
step moves two lines vertically or two columns horizontally. The terminal
must distinguish `Ctrl+Shift` from `Ctrl`; otherwise the shifted mappings
cannot control the preview separately. Other Telescope mappings are preserved.
The `telescope` table in `lua/keymaps.lua` reaches the plugin through
`functions.plugins`.

Related pages: [[Plugins]], [[Operations]].
