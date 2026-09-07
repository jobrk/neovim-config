# Configuration ownership

The original centralisation plan is implemented. This document describes the
current architecture, including the later reliability audit changes.

Core editor options, mappings and autocommands live in `init.lua`. Plugin
specs live in `lua/plugins/`, one returned table per file. Cross-cutting policy
and substantial helpers stay in flat `lua/*.lua` modules; there is no
`lua/config/` or `lua/core/` hierarchy.

| Module | Owns |
|---|---|
| `ui.lua` | Border style and Telescope border glyphs |
| `search.lua` | Search exclusions shared by file and grep pickers |
| `keymap_policy.lua` | Mapping timeout, WhichKey delay and leader groups |
| `lsp.lua` | Completion capabilities shared by native and specialised LSPs |
| `tooling.lua` | Mason package inventory, LSP allowlist and parser inventory |
| `parsers.lua` | Install/update declared parsers and propagate failures |
| `formatting.lua` | Web formatter choice and format-on-save policy |
| `debugging.lua` | Python/Node/CodeLLDB adapters and project interpreter/DLL selection |
| `mason_registry.lua`, `mason_netcoredbg.lua` | Temporary native netcoredbg package recipe until Mason's upstream registry catches up |
| `statusline.lua` | Mini statusline implementation |

Plugin-specific choices remain beside their plugin. For example, Java's
workspace and per-buffer lifecycle belong in `plugins/jdtls.lua`; TypeScript's
Vue bridge belongs in `after/lsp/ts_ls.lua`.

WhichKey now owns key-guide rendering through its public configuration API.
The previous custom MiniClue buffer/extmark rewriting implementation has been
removed. Mini still owns its other editing modules, statusline and sessions.

Installing a tool and activating an LSP are separate decisions. The ordinary
LSP allowlist is explicit; JDTLS, Roslyn and Rustaceanvim own specialised server
lifecycles. Mason is the sole installer inventory for debug adapters, while
nvim-dap and language integrations own their adapter configurations.

Provisioning uses `scripts/run.lua` through `check.sh` so Lua exceptions return
a nonzero shell status. The three provision tasks are separate to isolate
plugin restoration, parser alignment and Mason installation. `tests/smoke.lua`
checks the installed configuration and runs `tests/behavior.lua` for formatter
selection and buffer/client lifecycle regressions.

Do not extract tiny repeated calls merely to reduce line count. File-local
action/adapter tables remain appropriate, and an autocommand naming helper is
still unnecessary. Loading DAP/Neotest before their first keypress is deliberate;
Blink is explicitly eager because LSP setup consumes its capabilities.
