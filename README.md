# nvim

Personal Neovim configuration for Lua, Go, C#/.NET, Java, Python, Rust and
JavaScript/TypeScript, including Vue. Uses native Neovim LSP, Tree-sitter,
Blink completion, Telescope, Conform, Neotest and nvim-dap.

## Requirements

- Neovim 0.12+; CI tests 0.12.5 on Linux. Also used on macOS ARM.
- git, ripgrep, make, a C compiler, curl, tar and unzip.
- Tree-sitter CLI 0.27+ to build the configured parsers.
- Node.js 24 LTS and npm, Python 3, Go, Rust/Cargo and the .NET SDK for
  installing the full tool inventory. Python must support `venv`.
- JDK 21+ to run JDTLS; CI uses JDK 25. Individual projects may require
  additional JDKs, SDKs or language versions.
- A Nerd Font, or set `vim.g.have_nerd_font = false` in `init.lua`.

Machine-level packages belong in the machine provisioning configuration.
`provision.sh` checks prerequisites and installs editor tooling through Mason;
it does not install system runtimes. CI lists concrete runtime versions in
[ci.yml](.github/workflows/ci.yml).

## Setup and verification

For a standalone clone (the dotfiles repo already includes this as a submodule):

```sh
git clone https://github.com/jobrk/neovim-config.git ~/.config/nvim
```

Then, for either installation:

```sh
cd ~/.config/nvim
git config core.hooksPath .githooks
./provision.sh
./check.sh
nvim
```

Provisioning restores plugins from `lazy-lock.json`, installs **and updates**
the declared parsers to their plugin's revisions, then installs missing Mason
tools. Each stage returns a failing process status on errors. The smoke suite
checks plugin commits, tools, parser queries, LSP activation and behavioural
regressions. Use `./check.sh path/to/task.lua` for another headless Lua check;
a raw `nvim --headless +luafile ... +qa` can report Lua errors while exiting 0.

Use `:checkhealth`, `:Mason`, `:ConformInfo` and `:LspInfo` for interactive
troubleshooting. Health warnings about optional providers or unused tools do
not necessarily indicate a broken workflow.

## Language support

| Language | LSP / completion | Formatting | Tests / debugging |
|---|---|---|---|
| Lua | lua_ls, lazydev | StyLua | — |
| Go | gopls | goimports | Neotest Go, Delve |
| Python | Pyright and Ruff | Ruff imports, then format | Neotest Python, debugpy |
| Rust | Rustaceanvim / rust-analyzer | LSP rustfmt | Rustaceanvim Neotest (`cargo test`), CodeLLDB |
| JS / TS | ts_ls and ESLint | Prettier or explicit oxfmt | Neotest Jest/Vitest, Node DAP |
| Vue | vue_ls and ts_ls with Vue's TS plugin | Prettier or explicit oxfmt | Project-specific Jest/Vitest; Node DAP for JS/TS |
| Java | nvim-jdtls, per project and buffer | JDTLS | Java test/debug extensions via nvim-jdtls |
| C# | Roslyn | LSP | Neotest .NET, netcoredbg |
| Terraform / Puppet / SQL / Zig | terraformls / puppet / sqlls / zls | LSP where supported | — |
| JSON / Jinja | jsonls / jinja_lsp | Prettier for JSON | — |

The explicit LSP allowlist is in `lua/tooling.lua`. Installing another server
with Mason does not automatically enable it. JDTLS, Roslyn and Rustaceanvim
manage their own servers; external formatters run through Conform.

Test runners and project dependencies are **project requirements**: install
pytest, Jest or Vitest where needed; restore/build .NET projects; install the
project's Rust toolchain. Rust tests do not require cargo-nextest. Use
`:RustLsp testables` / `:RustLsp debuggables` for Rust's extended workflows.
Python debugging selects an active virtualenv, then a nearby `.venv`/`venv`,
then system Python. Node launch configurations need runnable JS/TS or a
project-specific configuration with the right build output/source maps.
For .NET, build first; the DLL prompt suggests a nearby Debug output. The
local Mason recipe selects Samsung's native ARM macOS debugger, because the
upstream registry still supplies an Intel build. Java
uses `<leader>jt` for a method and `<leader>jT` for a class.

Tree-sitter highlighting includes 40 languages. Highlighting alone does not
imply LSP, tests or debugging support. C/C++ currently have no configured LSP
and intentionally skip formatting.

## Editing and formatting policy

Indentation defaults to two spaces, with vim-sleuth adapting to existing files
and Neovim's EditorConfig support honouring project settings. Persistent undo
is enabled. Swap files live under Neovim's state directory for crash recovery;
a temporary backup protects writes, without leaving backup files in projects.

Web files default to Prettier. The nearest explicit Prettier or oxfmt config
chooses the formatter, stopping at the Git root. Prettier wins if both exist
in the same directory; merely having oxfmt installed does not opt a project
in. `package.json`'s `prettier` field also counts. This policy covers JS/TS,
Vue, CSS, HTML, JSON, Markdown, YAML and the other web formats listed in
`lua/formatting.lua`. Web formatting never falls back to a competing LSP.

- `:WebFormatter prettier`, `:WebFormatter oxfmt`, `:WebFormatter auto`:
  choose/reset the current buffer's formatter.
- `<leader>f`: format manually.
- `<leader>tF`: toggle this buffer's format-on-save.
- `:FormatDisable`: disable format-on-save globally; `:FormatDisable!`:
  current buffer only. `:FormatEnable`: clear global and current-buffer flags.

## Navigation and UI

Space is leader. Hold Space for the WhichKey guide; group names and timing
live in `lua/keymap_policy.lua`. The guide only triggers on leader mappings.
Search lives under `<leader>s`, code actions under `<leader>c`, debugging under
`<leader>d` and tests/toggles under `<leader>t`. `<leader>q` fills the diagnostic
location list. `<leader>th` toggles inlay hints for the current buffer.

Noice handles messages/command input, Telescope handles selection, and the
shared border policy lives in `lua/ui.lua`. Mini provides the statusline,
sessions and small editing helpers. Catppuccin uses the Mocha palette.

## Updating and rolling back

1. Start with a clean worktree. Use `:Lazy update` when intentionally updating
   plugins; review the lockfile diff.
2. Run `./provision.sh` to align parsers with the pinned Tree-sitter plugin.
3. Run `./check.sh` and `~/.local/share/nvim/mason/bin/stylua --check .`.
4. Exercise the languages you use, then commit the lockfile and config together.

`lazy-lock.json` pins plugins. Parser revisions come from the pinned
nvim-treesitter plugin. Most Mason tools and their registries are **not pinned**;
`provision.sh` installs missing tools, and `:Mason` handles deliberate updates.
The exception is netcoredbg: `tooling.netcoredbg_version` and the small local
registry pin 3.2.0-1092 (3.1.3-1062 on Intel macOS, which has no 3.2 release).
Provisioning migrates an existing install to that version. Remove the local
recipe when Mason's upstream package supports the required native builds.
This is not a fully reproducible toolchain lock.

To undo a bad committed update, revert that commit and run `./provision.sh`
again. `:Lazy restore` alone restores plugin versions but does not guarantee
installed parsers match them. Roll back a Mason tool separately if needed.
In the parent dotfiles repo, commit the new Neovim submodule pointer after
pushing this repo.

See [AGENTS.md](AGENTS.md) for contribution conventions and
[CONFIG_CENTRALISATION.md](CONFIG_CENTRALISATION.md) for module ownership.
