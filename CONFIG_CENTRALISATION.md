# Neovim configuration centralisation plan

> Status: implemented. The autocommand-group helper remains intentionally
> deferred because the existing call sites are clearer without a global
> utility.

## Goal

Put genuine cross-cutting policy in one place while keeping plugin-specific
configuration beside the plugin that consumes it. The aim is to prevent drift,
not to minimise line count at the cost of readability or lazy-loading behavior.

The current configuration already has one good central module:
`lua/tooling.lua` owns the Mason and Tree-sitter installation inventories. We
should extend that pattern with a few small, flat modules rather than introduce
a `lua/config/` or `lua/core/` hierarchy.

## Summary

| Priority | Policy or pattern | Current problem | Proposed owner |
|---|---|---|---|
| P0 | Floating-window borders | `single` and its glyphs are restated in core, lazy.nvim, Noice, and Telescope | `lua/ui.lua` |
| P0 | Search exclusions | grep and file search maintain separate lists and have already drifted | `lua/search.lua` |
| P1 | Mapping timing and clue groups | `300` ms and leader-group descriptions are restated in different files | `lua/keymap_policy.lua` |
| P1 | LSP client capabilities | Blink capabilities are built independently for normal LSP clients and JDTLS | `lua/lsp.lua` |
| P1 | Tool identities | some tools, especially `delve`, appear in more than one installer-facing list | extend `lua/tooling.lua` |
| P1 | Large `mini.nvim` configuration | clue layout and statusline logic obscure the module setup and are hard to test separately | `lua/mini_clue.lua` and `lua/statusline.lua` |
| P2 | Repeated adapter/action declarations | Neotest adapters and DAP actions repeat a roster within their own files | file-local data tables |
| P2 | Autocommand group naming | ten group declarations use a mix of `kickstart-*` and unprefixed names | optional helper after higher-value work |

## 1. Central UI policy

### What is repeated

- `init.lua` sets `vim.opt.winborder = 'single'`.
- lazy.nvim separately sets `ui.border = 'single'` because lazy.nvim does not
  inherit `winborder`.
- Noice separately sets `{ border = { style = 'single' } }` for four views.
- Telescope spells out the single-border glyphs once for normal pickers and
  three more times for the joined `ui-select` layout.
- neo-tree uses `popup_border_style = ''`, its special value for inheriting
  `winborder`.
- mini.clue already inherits `winborder`; its custom layout should continue to
  control geometry only.

There are currently six literal occurrences of `'single'`, plus the Telescope
glyph tables. Changing the border is therefore a multi-file operation.

### Proposed API

Create `lua/ui.lua` as the owner of semantic UI tokens:

```lua
local M = {}

M.border = {
  style = 'single',
  horizontal = '─',
  vertical = '│',
  top_left = '┌',
  top_right = '┐',
  bottom_right = '┘',
  bottom_left = '└',
}

function M.telescope_borderchars()
  local b = M.border
  return {
    b.horizontal,
    b.vertical,
    b.horizontal,
    b.vertical,
    b.top_left,
    b.top_right,
    b.bottom_right,
    b.bottom_left,
  }
end

return M
```

Functions should return fresh tables where a plugin may mutate its options.
The module should hold primitives and small adapters, not whole plugin configs.

### Implementation

1. Require `ui` near the top of `init.lua` and set
   `vim.opt.winborder = ui.border.style`.
2. Set lazy.nvim's explicit border from the same value.
3. Build Noice's four view borders from `ui.border.style` in its `opts`
   function.
4. Replace Telescope's literal glyph arrays with `ui` helpers, including a
   helper for the joined prompt/results/preview border used by `ui-select`.
5. Keep neo-tree's empty-string inheritance sentinel, with a comment pointing
   to `lua/ui.lua`; do not replace it with the literal style because that would
   stop it following `winborder`.
6. Do not add border settings to plugins that already inherit `winborder`.

### Acceptance check

Changing only `ui.border.style` and its glyph set must update the core float,
lazy.nvim, Noice, Telescope, neo-tree, and mini.clue appearance.

## 2. One search-exclusion policy

### What is repeated and already drifting

Telescope live grep excludes:

- `.git`
- `.worktrees`
- `.claude/worktrees`

The `<C-p>` file picker excludes only `.git` and `.worktrees`. As a result,
Claude worktrees can reappear in file search even though they are hidden from
grep. The two consumers also need different syntaxes: ripgrep globs and Lua
patterns.

### Proposed API

Create `lua/search.lua` with one semantic directory list and adapters for each
consumer:

```lua
local M = {}

M.excluded_dirs = {
  '.git',
  '.worktrees',
  '.claude/worktrees',
}

function M.rg_exclude_globs()
  -- Return entries such as `--glob=!**/.git/*`.
end

function M.telescope_ignore_patterns()
  -- Return escaped Lua patterns such as `%.git/`.
end

return M
```

### Implementation

1. Move only the directory policy into `search.lua`.
2. Keep Telescope's base ripgrep arguments (`--hidden`, `--smart-case`, line
   and column output) in `telescope.lua`; append `search.rg_exclude_globs()`.
3. Give `find_files` the result of `search.telescope_ignore_patterns()`.
4. Reuse the same patterns for any future file, grep, or workspace picker.
5. Add a smoke assertion that both adapters contain every semantic exclusion.

This fixes the existing `.claude/worktrees` inconsistency as part of the move.

## 3. Mapping policy: timing and group metadata

### What is repeated

- `vim.opt.timeoutlen` and mini.clue's popup delay are related key-query
  settings, but they have different semantics and should be named separately.
- Leader namespaces are encoded in key descriptions throughout plugin files
  and manually restated as clue groups in `mini.lua`.

The distributed keymaps themselves should remain with their plugins so lazy.nvim
can create the correct lazy-loading stubs. Only shared policy should move.

### Proposed API

Create `lua/keymap_policy.lua`:

```lua
return {
  mapping_timeout_ms = 300,
  clue_delay_ms = 200,
  groups = {
    { mode = 'n', keys = '<Leader>c', desc = '+[C]ode' },
    { mode = 'n', keys = '<Leader>d', desc = '+[D]ocument & [D]ebug' },
    { mode = 'n', keys = '<Leader>r', desc = '+[R]ename' },
    { mode = 'n', keys = '<Leader>s', desc = '+[S]earch & [S]ession' },
    { mode = 'n', keys = '<Leader>t', desc = '+[T]oggle & [T]ests' },
    { mode = 'n', keys = '<Leader>w', desc = '+[W]orkspace' },
    { mode = { 'n', 'x' }, keys = '<Leader>h', desc = '+Git [H]unk' },
  },
}
```

### Implementation

1. Set `timeoutlen` from `mapping_timeout_ms`.
2. Set mini.clue's `window.delay` from `clue_delay_ms`; showing a clue is
   independent of Neovim's mapping timeout.
3. Expand multi-mode group entries into mini.clue's required clue tables in a
   small function inside `mini.lua` or `mini_clue.lua`.
4. Keep every actual key mapping and description in its current plugin file.
5. Add a smoke check that the leader groups referenced by plugin keys have a
   group description where one is expected.

## 4. LSP defaults

### What is repeated

Both `lspconfig.lua` and `jdtls.lua` call
`require('blink.cmp').get_lsp_capabilities()`. JDTLS must be started manually,
so the wildcard `vim.lsp.config('*', ...)` does not remove the need to provide
the same capabilities to `jdtls.start_or_attach()`.

### Proposed API

Create `lua/lsp.lua`:

```lua
local M = {}

function M.capabilities()
  return require('blink.cmp').get_lsp_capabilities()
end

return M
```

The function form returns a fresh table and avoids exposing a mutable shared
table to two clients.

### Implementation

1. Use `require('lsp').capabilities()` in the wildcard LSP configuration.
2. Use the same function in JDTLS.
3. Keep server-specific settings, roots, bundles, and `on_attach` behavior in
   their current plugin files.

This is intentionally small. A universal language registry would hide useful
differences between standard LSP clients, JDTLS, and Roslyn.

## 5. Extend the existing tooling inventory

`lua/tooling.lua` is already the right owner for installation policy. It can be
made more expressive without turning it into a generated language framework.

### Proposed changes

- Give shared tools stable names before constructing consumer lists:

  ```lua
  local debug_adapters = {
    go = 'delve',
    dotnet = 'netcoredbg',
  }
  ```

- Build both `mason` and `mason_dap` from those names so `delve` is not an
  unrelated literal in two lists.
- Optionally expose named tool groups (`lsp`, `formatters`, `debuggers`) and
  flatten them into the existing `mason` list. Consumers should continue to
  receive the exact flat arrays their plugins expect.
- Keep Tree-sitter parser names separate. A parser, LSP server, formatter, and
  test adapter often use different identifiers, and forcing them into a single
  per-language schema would add mapping code without removing meaningful drift.

## 6. Decompose the `mini.nvim` coordinator

This is primarily a maintainability change rather than deduplication.
`lua/plugins/mini.lua` is about 300 lines because it now contains a responsive
clue-grid renderer and a custom statusline in addition to eight mini module
setups.

### Proposed modules

- `lua/mini_clue.lua`
  - owns the bottom grid renderer;
  - consumes `keymap_policy.groups` and `keymap_policy.clue_delay_ms`;
  - exports `setup()`.
- `lua/statusline.lua`
  - owns statusline highlight setup, diff/diagnostic sections, and recording
    redraw behavior;
  - exports `setup()`.
- `lua/plugins/mini.lua`
  - remains the only lazy.nvim plugin spec;
  - sets up `mini.ai`, `mini.surround`, `mini.pairs`, `mini.hipatterns`,
    `mini.sessions`, and `mini.icons`;
  - calls the two helpers above.

The split keeps the repository's one-spec-per-plugin rule: helper modules are
not plugin specs and are not placed under `lua/plugins/`.

### Testing improvement

Expose a pure `layout(lines, columns)`-style helper from `mini_clue.lua` so the
smoke test can verify:

- at most six rows when the terminal is wide enough;
- column-major ordering;
- stable truncation of long labels;
- one-column fallback in a narrow terminal.

The current manual terminal test should become a repeatable assertion.

## 7. File-local table-driven cleanup

These repetitions should be reduced locally, not moved into global policy.

### Neotest adapters

`neotest.lua` lists each adapter once as a lazy.nvim dependency and again as a
Lua module passed to `neotest.setup()`. Define a local roster containing plugin
and module names, then derive both tables. This prevents adding an adapter to
only one half of the file.

### DAP actions

Most DAP key specs differ only by key, method, and description. A file-local
`dap_action(method)` helper or a small action table can remove repeated wrapper
functions while keeping the mappings visible in `dap.lua`.

Conditional breakpoint, hover, preview, and any action with arguments should
remain explicit.

### Statusline thresholds

The truncation threshold `75` is repeated for diff and diagnostics. Name it
once inside `statusline.lua` (for example `local detail_width = 75`). The other
thresholds (`40`, `120`, `140`) have different meanings and should retain
separate names.

### Mini hipatterns

The FIXME/HACK/TODO/NOTE declarations can be generated from a local table of
word-to-highlight mappings. Keep this local to the mini plugin; it is not
cross-cutting policy.

## 8. Autocommand groups

There are ten direct augroup declarations and their names mix inherited
`kickstart-*` names with `restore-*`, `statusline-*`, and other prefixes.

After the higher-value changes, add a small helper only if consistent naming is
desired:

```lua
local function augroup(name)
  return vim.api.nvim_create_augroup('jobrk-' .. name, { clear = true })
end
```

This helper must not become a generic utility dumping ground. Buffer-specific
group lifetime and the LSP highlight group's reuse still need to remain clear
at the call site.

## What should not be centralised

### Plugin dependency declarations

`plenary.nvim`, `nvim-nio`, Treesitter, and Blink appear in multiple plugin
specs because each consumer has an independent dependency edge. Replacing
those strings with constants would save almost nothing and make the lazy.nvim
graph less readable.

### All keymaps

Plugin keys belong in each lazy.nvim spec. Moving them into a global keymap
module can eagerly load plugins or require a second hand-maintained loading
table. Centralise group metadata and timing only.

### All language configuration

Do not generate Conform, LSP, DAP, Neotest, and Tree-sitter configs from one
large language matrix. Their identifiers and lifecycle requirements differ,
especially for JDTLS and Roslyn. Keep `tooling.lua` as an installation
inventory and retain behavior beside each plugin.

### Generic `setup()` wrappers

The repeated `require('plugin').setup(...)` shape is the normal public API of
each plugin, not duplicated policy. Wrapping it would add indirection without a
single behavior to change.

### Coincidental numeric values

Only combine numbers that represent the same decision. For example,
`updatetime = 250` and Blink's documentation delay of `250` have unrelated
semantics and should not share a constant.

## Target layout

```text
init.lua
lua/
  keymap_policy.lua     shared mapping timing and leader groups
  lsp.lua               shared client capabilities
  mini_clue.lua         responsive clue renderer and setup
  search.lua            semantic search exclusions and adapters
  statusline.lua        custom mini.statusline implementation
  tooling.lua           installation inventories
  ui.lua                border style and glyph policy
  plugins/              one lazy.nvim spec per plugin, unchanged in purpose
```

## Implementation sequence

1. **Add policy tests first.** Extend `tests/smoke.lua` for UI style, search
   adapter completeness, key timing, and pure clue-layout behavior.
2. **Centralise UI policy.** Add `ui.lua`, migrate core/lazy/Noice/Telescope,
   and visually check representative floats.
3. **Centralise search exclusions.** Add `search.lua`, fix the Claude-worktree
   file-search omission, and exercise both file and grep pickers.
4. **Centralise mapping policy.** Add `keymap_policy.lua` and migrate
   `timeoutlen`, clue delay, and leader groups without moving plugin keymaps.
5. **Extract mini helpers.** Move clue layout and statusline implementation out
   of the plugin spec, preserving behavior and adding direct layout tests.
6. **Share LSP capabilities and named tools.** Add `lsp.lua` and refine
   `tooling.lua`; verify standard LSP, JDTLS, DAP, and Mason provisioning.
7. **Apply file-local cleanups.** Derive the Neotest roster and reduce the DAP
   action wrappers.
8. **Reassess augroup naming.** Standardise it only if the helper still makes
   the call sites clearer after the larger files have been split.

After every step run:

```sh
stylua --check .
nvim --headless "+luafile tests/smoke.lua" +qa
nvim --headless +qa
```

For UI steps, also open an actual terminal session and verify lazy.nvim,
Telescope, Noice, neo-tree, and the main and nested mini.clue panels. Headless
startup alone cannot validate geometry or joined borders.

## Definition of done

- A border-style change has one semantic source of truth.
- File and grep search cannot disagree about excluded directories.
- Mapping timeout and clue delay share one policy value.
- Leader group labels are declared once while mappings stay plugin-local.
- Standard LSP and JDTLS capabilities are produced by one function.
- Mason/DAP shared tool identities are named once.
- `mini.lua` returns to being a readable plugin coordinator.
- The smoke suite covers the newly extracted pure policy/layout functions.
- Lazy-loading boundaries and current user-visible behavior remain unchanged,
  except for the intentional search-exclusion fix.
