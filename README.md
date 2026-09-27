# Neovim configuration

A portable Neovim configuration with pinned plugin revisions and an Obsidian
knowledge base.

## Installation

Requires Neovim `0.12.5` or a compatible newer stable release and Git `2.19`
or newer. Tree-sitter also requires a C compiler, `curl`, `tar`, and
`tree-sitter-cli >= 0.26.1`.

```sh
git clone https://github.com/hardcodd/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

Plugins install automatically on first launch. See the
[operations guide](Neovim%20Knowlage/Operations.md) for setup, verification,
and maintenance.
