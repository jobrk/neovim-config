#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

for tool in git rg make cc tree-sitter curl tar unzip node npm python3 java go cargo dotnet; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing prerequisite: %s (see README.md)\n' "$tool" >&2
    exit 1
  fi
done

provision_log=$(mktemp "${TMPDIR:-/tmp}/nvim-provision.XXXXXX")
trap 'rm -f "$provision_log"' EXIT

run() {
  printf '==> %s\n' "$1"
  shift
  if ! "$@" > "$provision_log" 2>&1; then
    cat "$provision_log" >&2
    return 1
  fi
}

run Plugins ./check.sh scripts/provision_plugins.lua
run Parsers ./check.sh scripts/provision_parsers.lua
run Tools ./check.sh scripts/provision_tools.lua
