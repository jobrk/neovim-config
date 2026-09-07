# AGENTS.md - Neovim Configuration

Personal Neovim configuration written in Lua, based on kickstart.nvim.
Uses lazy.nvim as the plugin manager. Targets a polyglot workflow
(Lua, Go, C#/.NET, Java, Python, Rust, TypeScript/JavaScript).

## Repository Structure

```
init.lua               # Entry point: options, keymaps, autocommands, lazy.nvim bootstrap
lua/plugins/           # One file per plugin spec (lazy.nvim format)
lua/*.lua              # Flat shared policy and focused implementation helpers
after/lsp/             # Server settings merged after plugin-provided LSP configs
.stylua.toml           # Lua formatter configuration
```

All core settings (options, keymaps, autocommands) live in `init.lua`.
Each plugin gets its own file in `lua/plugins/`. Cross-cutting policy (UI,
search, keymap timing, tooling, and LSP capabilities) and larger extracted
implementations (debugging and the statusline) use focused flat modules under
`lua/`; do not introduce `lua/config/` or `lua/core/` hierarchies.

## Build / Lint / Format Commands

GitHub Actions provisions the editor from scratch, checks formatting, and runs
`tests/smoke.lua`. This is a configuration smoke suite, not a library test suite.

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
  config file), otherwise `prettier`. The nearest explicit config wins, with
  Prettier winning same-directory conflicts. Web filetypes never use LSP fallback.
- Python: `ruff` (organize imports, then format); Go: `goimports`
- Other filetypes: LSP fallback (except C/C++ which skip formatting)

### Linting

No standalone linter config (no `.luacheckrc`, `selene.toml`). Rely on
`lua_ls` diagnostics via LSP inside Neovim.

### Checking the Config Loads

```sh
./provision.sh                          # restore plugins and install editor tooling
nvim --headless "+checkhealth" +qa     # run health checks
./check.sh                             # returns nonzero on Lua/query failures
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
require 'blink.cmp'                   -- preferred (no parens)
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

Use a narrow trigger when compatible with dependencies and first-key behaviour.
Blink is eager for LSP capabilities; DAP/Neotest use VeryLazy, and Rustaceanvim
loads its own filetype integration. Typical triggers:
- `event`: `'VimEnter'`, `'InsertEnter'`, `'VeryLazy'`, `'BufWritePre'`
- `ft`: filetype string or list (`'java'`, `{ 'cs', 'razor' }`)
- `cmd`: command string or list (`'Neotree'`, `'ZenMode'`)
- `keys`: keymap definitions (table of `{ lhs, rhs, desc }`)

### Keymap Conventions

- Leader key is Space. WhichKey covers leader and navigation/window prefixes;
  `<leader>?` shows buffer-local mappings. Keep MiniAi hint descriptions in
  `keymap_policy.lua` aligned with the configured text objects.
- Descriptions use bracket notation for the WhichKey guide: `'[S]earch [H]elp'`
- Standard namespace prefixes:
  - `<leader>s` -- Search
  - `<leader>c` -- Code
  - `<leader>d` -- Document / Debug
  - `<leader>r` -- Rename
  - `<leader>w` -- Workspace
  - `<leader>t` -- Toggle / Tests
  - `<leader>h` -- Git hunk
- Movement/visual keymaps use `{ silent = true }`.
- Run `./check.sh` after key-guide changes: `tests/keyguide.lua` exercises actual
  UI input, including immediate `gr` dispatch and deferred text-object hints.
- Local `map()` helper functions are acceptable inside `config` functions
  for conciseness (see `lspconfig.lua`, `gitsigns.lua`).

### Imports and Requires

```lua
-- Top of config function: assign to local
local blink = require 'blink.cmp'

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
  and `.nvim` suffix dropped (e.g., `zen_mode.lua`, `sleuth.lua`,
  `lspconfig.lua`, `dap.lua`).
- Local variables: `snake_case`.
- Augroup names: `'kickstart-<purpose>'` (inherited from kickstart.nvim).

### Comments

- Section headers use `-- [[ Section Name ]]` style.
- Inline doc comments for LSP: `---@diagnostic`, `---@type`, `---@param`.
- Short inline comments on the same line or the line above are fine.

## Key Design Decisions

- **Recovery**: swap files in `stdpath("state")/swap`, persistent undo, temporary
  write backups; no persistent backup files in projects. Two-space fallback
  indentation, with sleuth and EditorConfig adapting to the project.
- **Netrw disabled**: `vim.g.loaded_netrw = 1` in favor of neo-tree.
- **Mason as universal installer**: LSP servers, formatters, linters, DAP adapters.
  Uses a custom registry (`Crashdummyy/mason-registry`) for Roslyn.
- **Explicit LSP activation**: `tooling.lsp` is the mason-lspconfig allowlist.
  JDTLS, Roslyn and Rustaceanvim own Java, C# and Rust respectively. Java setup
  runs for every Java buffer, with a separate workspace per project.
- **Catppuccin mocha** colorscheme with transparent background.
- **ThePrimeagen-style keymaps**: centered scrolling (`<C-d>zz`), centered
  search (`nzzzv`), visual line move (`J`/`K`), black-hole delete, system
  clipboard yank.

## Files to Never Commit

Per `.gitignore`: `.luarc.json`, `spell/`, `tags`, `test.sh`.
`lazy-lock.json` IS committed — it pins plugin versions for reproducibility
(run `./provision.sh` after reverting an update to align parsers too). Mason
tools mostly remain unpinned; netcoredbg is the explicit exception in tooling.
Do not claim the plugin lockfile covers Mason tools.

## Adding a New Plugin

1. Create `lua/plugins/<plugin_name>.lua` returning a lazy.nvim spec (a table,
   never a bare string — `lazy.setup` imports the whole `plugins/` directory).
2. Run `stylua .` to format.
3. Run `./provision.sh` and `./check.sh`.
4. Update README language support or policies if behaviour changes.

To disable a plugin, set `enabled = false` in its spec; delete the file once
it's clearly not coming back.
