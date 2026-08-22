#!/usr/bin/env bash
set -euo pipefail

nvim --headless '+Lazy! restore' +qa
nvim --headless "+lua require('nvim-treesitter').install(require('tooling').treesitter, { max_jobs = 1 }):wait(900000)" +qa
nvim --headless '+MasonToolsInstallSync' +qa
