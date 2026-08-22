# nvim

Personal Neovim configuration. See [AGENTS.md](AGENTS.md) for structure and conventions.

## Requirements

- Neovim 0.12+
- git, ripgrep, make (telescope-fzf-native), node (some LSP servers)
- A Nerd Font (or set `vim.g.have_nerd_font = false` in `init.lua`)

## Setup

```sh
git clone <this repo> ~/.config/nvim
git -C ~/.config/nvim config core.hooksPath .githooks
~/.config/nvim/provision.sh
nvim
```

The provisioning script installs all plugins, configured Tree-sitter parsers,
language servers, formatters, and debug adapters. Use `:Mason` to inspect them.
