# 🧭 Remaining complexity

Further simplification now means giving up features or automation.

| Area | Simpler option | Recommendation |
| --- | --- | --- |
| 🪟 [Telescope borders](lua/plugins/telescope.lua) | Its Plenary borders cannot inherit `winborder`. | Keep explicit glyphs until supported; avoid a custom adapter. |
| 🎨 [Statusline](lua/statusline.lua) | Mini defaults; lose custom colors, layout and recording indicator. | Simplify unless you value those details. |
| 🧭 [Web formatting](lua/plugins/conform.lua) | Prettier by default; choose oxfmt manually. | Keep detection if you regularly use both. |
| 🐞 [Debugging](lua/plugins/dap.lua) / [Neotest](lua/plugins/neotest.lua) | Remove unused language adapters and optional debugger UI. | Trim based on actual usage. |
| ☕ Java / C# / Rust integrations | Basic LSP setup; lose specialized test/debug workflows. | Keep while you use these languages. |
| 🍎 [netcoredbg recipe](lua/mason_netcoredbg.lua) | Mason's upstream package. | Remove only after verifying native Apple Silicon support. |
| 📦 [Provisioning](provision.sh) / [inventories](lua/tooling.lua) | Manual plugin, parser and tool installation. | Keep for easier setup and rollback. |
| 💾 [Mini](lua/plugins/mini.lua) / [WhichKey](lua/plugins/which_key.lua) | Fewer session, highlight and hint customizations. | Remove conveniences you never use. |

🔧 **Machine issue:** `JAVA_HOME` points to missing Temurin 26; Temurin 27 is installed.
