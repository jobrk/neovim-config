# AGENTS.md — Neovim configuration

Personal Lua configuration based on kickstart.nvim, using lazy.nvim.

## Organization

- `init.lua`: editor options, general mappings, autocommands and lazy.nvim bootstrap.
- `lua/plugins/`: one lazy.nvim table spec per plugin. Keep its settings, mappings and helpers together.
- `after/lsp/`: native server overrides merged after plugin-provided defaults.
- `lua/tooling.lua`: shared Mason packages, LSP allowlist and parser inventory.
- Other flat `lua/` modules are for substantial implementations or real shared consumers, such as the statusline and parser installation.
- Prefer a small amount of repetition over tiny wrapper modules or custom configuration schemas. Do not add `lua/config/` or `lua/core/` hierarchies.

## Editing conventions

- Run `stylua .` and `stylua --check .`: two spaces, 160 columns, single quotes preferred, bare calls where supported.
- Each plugin file returns a table, never a bare string. Prefer `opts` unless setup requires procedural logic.
- Spec order: name, `enabled`/`branch`/`version`, `ft`/`event`/`cmd`, `build`, `dependencies`, `keys`, `opts`, `config`.
- Use snake_case for files and locals. Use `-- [[ Section Name ]]` for major sections.
- Keep comments focused on reasons, exceptions and useful examples.
- Use narrow lazy-loading triggers when compatible with dependencies and first-key behavior. Blink is eager for capabilities; DAP/Neotest use VeryLazy; Rustaceanvim owns its filetype integration.
- Use `pcall` for optional/fallible operations and executable checks for external tools. Keep error handling proportionate.

## Behavior to preserve

- Space is leader. Search uses `<leader>s`, code `<leader>c`, document/debug `<leader>d`, rename `<leader>r`, workspace `<leader>w`, tests/toggles `<leader>t`, Git hunks `<leader>h`.
- Mapping descriptions use bracket mnemonics such as `'[S]earch [H]elp'`. Movement/visual mappings are silent. Plugin mappings stay with their plugin.
- Use Neovim's global options where plugins support them. Keep border style in `init.lua` via `winborder`; Telescope's Plenary borders require explicit glyphs. Avoid restating plugin defaults.
- WhichKey settings and custom MiniAi hints live in `plugins/which_key.lua`; custom objects live in `plugins/mini.lua`. Preserve immediate `gr` dispatch and fast text objects.
- Two-space fallback indentation, adapted by Sleuth and EditorConfig. Persistent undo, state-directory swap files and temporary write backups; no retained project backups.
- Mason installs tools; `tooling.lsp` explicitly enables ordinary servers. JDTLS, Roslyn and Rustaceanvim own Java, C# and Rust. Java setup runs for every Java buffer with a workspace per project.
- Conform owns formatting. Web files use the nearest explicit Prettier/oxfmt config, Prettier wins ties, and web files never use LSP fallback. Python runs Ruff imports then formatting; Go uses goimports; Lua uses StyLua. C/C++ skip formatting.
- The local netcoredbg registry supports native Apple Silicon builds and pins its version through `tooling.lua`.

## Verification and updates

There is no configuration test suite. CI checks formatting. After changes, launch Neovim and exercise the affected workflow; use `:checkhealth`, `:ConformInfo`, `:Mason` and `:LspInfo` as needed.

Run `./provision.sh` after adding plugins/tools or changing the lockfile. It restores plugins, aligns parsers and installs missing Mason packages, returning nonzero on failure. Update README.md when user-facing behavior changes.

`lazy-lock.json` is committed and pins plugins. Parser revisions come from the pinned Tree-sitter plugin. Most Mason tools are unpinned; netcoredbg is the exception. Preserve unrelated lockfile edits.

Never commit `.luarc.json`, `spell/`, `tags` or `test.sh`. Enable the formatting hook on a fresh clone with `git config core.hooksPath .githooks`.
