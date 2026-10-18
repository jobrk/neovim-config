#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

for tool in nvim git rg make cc tree-sitter curl tar unzip node npm python3 java go cargo dotnet; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing prerequisite: %s (see README.md)\n' "$tool" >&2
    exit 1
  fi
done

provision_log=$(mktemp "${TMPDIR:-/tmp}/nvim-provision.XXXXXX")
trap 'rm -f "$provision_log"' EXIT

# Reload plugin code after restore before using it to install parsers and tools.
for stage in plugins parsers tools; do
  printf '==> %s\n' "$stage"
  if ! NVIM_PROVISION_STAGE="$stage" nvim --headless -i NONE '+lua dofile("scripts/provision.lua")' > "$provision_log" 2>&1; then
    cat "$provision_log" >&2
    exit 1
  fi
done
