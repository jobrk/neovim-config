#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
export NVIM_TASK="${1:-tests/smoke.lua}"
exec nvim --headless -i NONE '+lua dofile("scripts/run.lua")'
