# Neovim Configuration Review

This config is already coherent and restrained: a keyboard-first, tmux-integrated IDE centered on Telescope, native LSP, completion, formatting, testing, and debugging. The recommendations below are ordered by likely value.

| Priority | Area | Observation | Suggested change | Type |
| --- | --- | --- | --- | --- |
| High | LSP lifecycle | Each qualifying `LspAttach` recreates the `kickstart-lsp-detach` augroup with `clear = true`, removing detach handlers created for previously attached buffers. | Make the `LspDetach` handler buffer-local, or define one global handler outside `LspAttach`. | Correctness fix |
| Medium | Python tooling | Mason installs `flake8` and `mypy`, but the config does not invoke either. Python currently uses Pyright, Ruff LSP, and Ruff through Conform. | Remove `flake8` and `mypy` unless they are run externally, or add an intentional lint/type-check workflow for them. | Maintenance |
| Medium | .NET debugging | The DAP launcher assumes `bin/Debug/net*/` is under the current working directory. Selecting the final lexical glob result does not reliably identify the newest target framework or the correct project in a solution. | Find the nearest `.csproj`, discover its output DLL, and optionally remember the last selected executable. | Reliability / workflow |
| Medium | Telescope grep | Global ripgrep arguments include `--hidden` but do not explicitly exclude `.git`, while file finding does exclude it. | Add `--glob`, `!**/.git/*` to `vimgrep_arguments`. | Search correctness / performance |
| Medium | Recovery | Swap, backup, and write-backup files are disabled. Persistent undo protects saved edits but cannot recover unsaved work after a crash or killed session. | Consider enabling swap files; Neovim stores them in its centralized state location, avoiding project clutter. | Reliability preference |
| Usage-dependent | Test coverage | Neotest supports .NET, Jest, and Vitest, but not Go, Python, Java, or Rust despite their broader editor support. | Add adapters only for languages whose tests are regularly run outside Neovim. | Workflow expansion |
| Usage-dependent | Debug coverage | DAP supports .NET and Go, while Java, Python, and Rust currently have editing support but no debugger configuration. | Add only the debugger integrations that would replace a real external workflow. | Workflow expansion |
| Low | Diagnostics | `[e` and `]e` navigate errors only; warnings and lower severities require Telescope, a location list, or inline discovery. | Optionally add all-severity diagnostic navigation while retaining the error-only mappings. | Convenience |
| Low | Formatter feedback | `notify_on_error = false` can make failed save-formatting too quiet. | Enable formatter error notifications while keeping missing-formatter notifications quiet. | Observability |
| Low | Which-key | `<leader>l` is used for live grep and `<leader>lr` for LSP restart, but the `l` namespace is not documented as a which-key group. | Reconcile the namespace: register it for LSP, or move one of the mappings to match the existing search/LSP conventions. | Keymap consistency |
| Low | Sessions | Persistence is deliberately manual, with load-current and load-last mappings but no automatic restore or explicit stop behavior. | Keep it manual if predictability is preferred; otherwise consider automatic restore or a “do not save this session” action. | Preference |

## Choices worth keeping

| Area | Why it fits the apparent workflow |
| --- | --- |
| Flat plugin layout | Easy to navigate and appropriately sized for a personal configuration. |
| Native Neovim LSP APIs | Matches the current Neovim 0.12 setup and avoids unnecessary compatibility layers. |
| Project-aware oxfmt selection | Respects each repository's formatter choice instead of letting Mason's global binary determine behavior. |
| Blink + LuaSnip | Provides modern completion while retaining broad snippet support. |
| Treesitter main branch | The explicit parser list and guarded asynchronous installation are deliberate and robust. |
| mini.ai plus Treesitter textobjects | Keeps selection and structural movement powerful without adding overlapping plugin suites. |
| Manual session loading | Avoids surprising automatic restoration and remains easy to invoke when wanted. |
| Restrained UI | Noice, lualine, Catppuccin, and neo-tree add useful presentation without turning the config into a UI framework. |

## Verification notes

| Check | Result |
| --- | --- |
| Headless startup | Loaded successfully with Neovim 0.12.4. |
| Measured startup | Approximately 118 ms in the headless check; this is indicative rather than a full interactive benchmark. |
| StyLua check | Could not run from the shell because `stylua` is not on `PATH`; Mason does have it installed for use inside Neovim. |
| Existing worktree changes | The uncommitted `tsc` to `ts_ls` change and existing `nvim.log` were left untouched. |
