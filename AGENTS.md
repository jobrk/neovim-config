# AGENTS.md - Neovim Configuration

Personal Neovim configuration written in Lua, based on kickstart.nvim.
Uses lazy.nvim as the plugin manager. Targets a polyglot workflow
(Lua, Go, C#/.NET, Java, Python, Rust, TypeScript/JavaScript).

## Repository Structure

```
init.lua              # Entry point: options, keymaps, autocommands, lazy.nvim bootstrap
lua/plugins/          # One file per plugin spec (lazy.nvim format)
.stylua.toml          # Lua formatter configuration
```

All core settings (options, keymaps, autocommands) live in `init.lua`.
Each plugin gets its own file in `lua/plugins/`. There are no `lua/config/`,
`lua/core/`, or `after/` directories.

## Build / Lint / Format Commands

There is no Makefile, CI pipeline, or test suite. This is a Neovim config, not
a library.

### Formatting

**StyLua** is the Lua formatter. A pre-commit hook (`.githooks/pre-commit`,
enabled via `git config core.hooksPath .githooks`) rejects commits that fail
`stylua --check .` — on a fresh clone, re-run that git config command once.

```sh
stylua .
stylua --check .          # what the pre-commit hook runs
```

conform.nvim formats on save inside Neovim (5 s timeout). Formatter mapping:
- Lua: `stylua`
- JS/TS/JSX/TSX/JSON/JSONC/GraphQL: `oxfmt` if the project opts in (oxfmt
  config file or local node_modules install), otherwise `prettier`
- Python: `ruff` (organize imports, then format); Go: `goimports`
- Other filetypes: LSP fallback (except C/C++ which skip formatting)

### Linting

No standalone linter config (no `.luacheckrc`, `selene.toml`). Rely on
`lua_ls` diagnostics via LSP inside Neovim.

### Checking the Config Loads

```sh
./provision.sh                          # restore plugins and install editor tooling
nvim --headless "+checkhealth" +qa     # run health checks
```

## Code Style Guidelines

### Formatting Rules (enforced by `.stylua.toml`)

| Setting            | Value              |
|--------------------|--------------------|
| Indent             | 2 spaces           |
| Column width       | 160                |
| Line endings       | Unix (LF)          |
| Quotes             | Single preferred   |
| Call parentheses   | Omitted            |

StyLua's `call_parentheses = "None"` means bare calls are canonical:

```lua
require 'cmp'                   -- preferred (no parens)
vim.fn.stdpath 'data'           -- preferred
```

Both forms exist in the codebase; StyLua normalizes on format.

### Plugin Spec Pattern

Every file in `lua/plugins/` must return a lazy.nvim plugin spec:

```lua
-- lua/plugins/example.lua
return {
  'author/plugin-name',
  event = { 'VimEnter' },       -- lazy-load trigger
  opts = { ... },               -- declarative config (auto-calls setup())
}
```

Every file returns a single table spec: `return { 'author/plugin', opts = {} }`.
Bare string returns (`return 'author/plugin'`) are NOT valid — the directory
import in `lazy.setup` requires every module to return a table.

Spec key order: name, `enabled`/`branch`/`version`, `ft`/`event`/`cmd`,
`build`, `dependencies`, `keys`, `opts`, `config`.

Prefer `opts = {}` (declarative) over `config = function()` (imperative)
unless the plugin requires procedural setup logic.

### Lazy Loading Strategies

Use the narrowest trigger possible:
- `event`: `'VimEnter'`, `'InsertEnter'`, `'VeryLazy'`, `'BufWritePre'`
- `ft`: filetype string or list (`'java'`, `{ 'cs', 'razor' }`)
- `cmd`: command string or list (`'Neotree'`, `'ZenMode'`)
- `keys`: keymap definitions (table of `{ lhs, rhs, desc }`)

### Keymap Conventions

- Leader key is Space.
- Descriptions use bracket notation for which-key: `'[S]earch [H]elp'`
- Standard namespace prefixes:
  - `<leader>s` -- Search
  - `<leader>c` -- Code
  - `<leader>d` -- Document / Debug
  - `<leader>r` -- Rename
  - `<leader>w` -- Workspace
  - `<leader>t` -- Toggle / Tests
  - `<leader>h` -- Git hunk
- Movement/visual keymaps use `{ silent = true }`.
- Local `map()` helper functions are acceptable inside `config` functions
  for conciseness (see `lspconfig.lua`, `gitsigns.lua`).

### Imports and Requires

```lua
-- Top of config function: assign to local
local cmp = require 'cmp'

-- Inline require for one-off use in keymaps is fine
map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
```

### Error Handling

- Use `pcall` for optional/fallible operations (e.g., loading Telescope extensions):
  ```lua
  pcall(require('telescope').load_extension, 'fzf')
  ```
- Use `vim.fn.executable` / `vim.fn.has` for platform/tool checks.
- Minimal explicit error handling is normal for Neovim configs; don't over-engineer.

### Naming Conventions

- Plugin files: the plugin name, snake_cased, with any `vim-`/`nvim-` prefix
  and `.nvim` suffix dropped (e.g., `todo_comments.lua`, `sleuth.lua`,
  `lspconfig.lua`, `dap.lua`).
- Local variables: `snake_case`.
- Augroup names: `'kickstart-<purpose>'` (inherited from kickstart.nvim).

### Comments

- Section headers use `-- [[ Section Name ]]` style.
- Inline doc comments for LSP: `---@diagnostic`, `---@type`, `---@param`.
- Short inline comments on the same line or the line above are fine.

## Key Design Decisions

- **No swap/backup files**: `swapfile`, `backup`, `writebackup` all `false`.
- **Netrw disabled**: `vim.g.loaded_netrw = 1` in favor of neo-tree.
- **Mason as universal installer**: LSP servers, formatters, linters, DAP adapters.
  Uses a custom registry (`Crashdummyy/mason-registry`) for Roslyn.
- **jdtls excluded from mason-lspconfig auto-enable**: configured separately
  via `nvim-jdtls` with filetype trigger.
- **Catppuccin macchiato** colorscheme with transparent background.
- **ThePrimeagen-style keymaps**: centered scrolling (`<C-d>zz`), centered
  search (`nzzzv`), visual line move (`J`/`K`), black-hole delete, system
  clipboard yank.

## Files to Never Commit

Per `.gitignore`: `.luarc.json`, `spell/`, `tags`, `test.sh`.
`lazy-lock.json` IS committed — it pins plugin versions for reproducibility
(`:Lazy restore` rolls back to it after a bad update).

## Adding a New Plugin

1. Create `lua/plugins/<plugin_name>.lua` returning a lazy.nvim spec (a table,
   never a bare string — `lazy.setup` imports the whole `plugins/` directory).
2. Run `stylua .` to format.
3. Run `./provision.sh`.

To disable a plugin, set `enabled = false` in its spec; delete the file once
it's clearly not coming back.
