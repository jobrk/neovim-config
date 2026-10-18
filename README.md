# nvim

Personal Neovim configuration for Lua, Go, C#/.NET, Java, Python, Rust and
JavaScript/TypeScript, including Vue. Uses lazy.nvim, native LSP, Tree-sitter,
Blink, Telescope, Conform, Neotest and nvim-dap.

## Setup

Requires Neovim 0.12+, git, ripgrep, make, a C compiler, curl, tar, unzip and
Tree-sitter CLI 0.27+. Installing the full Mason inventory also needs Node.js
24 LTS/npm, Python 3 with venv, Go, Rust/Cargo, the .NET SDK and JDK 21+.
Install system runtimes through your machine provisioning. Use a Nerd Font,
or set `vim.g.have_nerd_font = false` in `init.lua`.

For a standalone clone (the dotfiles repo already includes this as a submodule):

```sh
git clone https://github.com/jobrk/neovim-config.git ~/.config/nvim
```

Then:

```sh
cd ~/.config/nvim
git config core.hooksPath .githooks
./provision.sh
nvim
```

Provisioning restores locked plugins, installs and updates declared parsers,
then installs missing Mason tools. Errors return a nonzero process status.
CI and the pre-commit hook check `stylua --check .`. Check changes by using the
affected editor workflow; `:checkhealth`, `:Mason`, `:ConformInfo` and `:LspInfo`
help with troubleshooting.

## Language support

| Language | LSP | Formatting | Tests / debugging |
| --- | --- | --- | --- |
| Lua | lua_ls, lazydev | StyLua | — |
| Go | gopls | goimports | Neotest Go, Delve |
| Python | Pyright, Ruff | Ruff imports then format | Neotest Python, debugpy |
| Rust | Rustaceanvim / rust-analyzer | LSP rustfmt | Rustaceanvim Neotest, CodeLLDB |
| JS / TS | ts_ls, ESLint | Prettier or explicit oxfmt | Neotest Jest/Vitest, Node DAP |
| Vue | vue_ls, ts_ls with Vue plugin | Prettier or explicit oxfmt | Project Jest/Vitest; Node DAP for JS/TS |
| Java | nvim-jdtls | JDTLS | JDTLS test/debug extensions |
| C# / Razor | Roslyn | LSP | Neotest .NET for C#, netcoredbg |
| Terraform / Puppet / SQL / Zig | terraformls / puppet / sqlls / zls | LSP where supported | — |
| JSON / Jinja | jsonls / jinja_lsp | Prettier for JSON | — |

Tool inventories live in `lua/tooling.lua`. Installing a server does not enable
it automatically. JDTLS, Roslyn and Rustaceanvim manage their own servers.
Tree-sitter also highlights languages without full LSP/debug support.

Install test runners and dependencies in each project: pytest, Jest/Vitest,
the Rust toolchain, or restored/built .NET projects. Rust uses `cargo test`;
`:RustLsp testables` and `:RustLsp debuggables` offer extended workflows.
Java uses `<leader>jt` for a method and `<leader>jT` for a class.

Python debugging selects the active virtualenv, a nearby `.venv`/`venv`, then
system Python. Node debugging may need project launch settings for build
output and source maps. Build .NET projects first; the DLL prompt suggests a
nearby Debug output.

## Editing and navigation

Indentation defaults to two spaces, adapted by Sleuth and EditorConfig.
Persistent undo is enabled. Swap files live in Neovim's state directory;
temporary write backups protect saves without retaining backups in projects.

Space is leader. WhichKey shows leader and navigation groups, window commands,
marks, registers and spelling suggestions; `<leader>?` shows buffer mappings.
Visual/operator hints wait for another key. Pause after `d`/`y`, then press
`i`/`a` for text-object hints. Fast text objects go directly to MiniAi.
Custom function, class and function-call hints live beside WhichKey's settings.

Set floating borders with `winborder` in `init.lua`. Lazy, WhichKey, Noice,
Neo-tree and DAP UI use it; Telescope requires its own border glyphs.

Search uses `<leader>s`, code `<leader>c`, debugging `<leader>d`, Git hunks
`<leader>h`, and tests/toggles `<leader>t`. `<C-p>` finds files, `<leader>l`
runs live grep, `<leader>n` reveals the file tree, `<leader>q` lists diagnostics,
and `<leader>th` toggles buffer inlay hints. Mini sessions save per directory;
`<leader>sl` loads the current directory's session and `<leader>sL` the latest.

Web files default to Prettier. The nearest explicit Prettier/oxfmt config wins,
stopping at the Git root; Prettier wins ties. A `package.json` Prettier field
counts, while an installed oxfmt binary alone does not. Web files never fall
back to LSP formatting. C/C++ skip formatting. Settings and selection logic
live together in `lua/plugins/conform.lua`.

- `<leader>f`: format manually; `<leader>tF`: toggle buffer format-on-save.
- `:WebFormatter prettier|oxfmt|auto`: select/reset the buffer's web formatter.
- `:FormatDisable`: disable globally; `:FormatDisable!`: disable this buffer.
- `:FormatEnable`: clear global and current-buffer disable flags.

## Updates and rollback

Use `:Lazy update` deliberately and review `lazy-lock.json`. Run
`./provision.sh` to align parsers, check formatting, then exercise the languages
you use before committing. To undo an update, revert it and provision again.
`:Lazy restore` alone does not align parsers.

The lockfile pins plugins; parser revisions follow nvim-treesitter. Most Mason
tools and registries are unpinned and are updated through `:Mason`. netcoredbg
uses a local recipe for native Apple Silicon support and pins 3.2.0-1092
(3.1.3-1062 on Intel macOS). Provisioning migrates existing installs. Remove
that workaround once the upstream package supplies the required native builds.
Roll back other Mason tools separately when needed.

In the parent dotfiles repo, commit the Neovim submodule pointer after pushing
this repo. See [AGENTS.md](AGENTS.md) for editing conventions.
