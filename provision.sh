#!/usr/bin/env bash
set -euo pipefail

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

run Plugins nvim --headless '+Lazy! restore' +qa
run Parsers nvim --headless "+lua require('nvim-treesitter').install(require('tooling').treesitter, { max_jobs = 1 }):wait(900000)" +qa
run Tools nvim --headless '+MasonToolsInstallSync' +qa
