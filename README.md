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
nvim   # lazy.nvim bootstraps and installs plugins on first launch
```

Language servers, formatters, and debug adapters install via Mason on first use (`:Mason` to inspect).
