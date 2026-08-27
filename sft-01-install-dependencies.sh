#!/usr/bin/env bash
# sft-01-install-dependencies.sh
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
set -euo pipefail

echo "input: pyproject.toml, uv.lock"
echo "output: .venv"

do_sync() {
  UV_TORCH_BACKEND="${UV_TORCH_BACKEND:-cu130}" uv sync
}

_make ".venv" "pyproject.toml" "uv.lock" -- do_sync

echo "input: pyproject.toml, uv.lock"
echo "output: .venv"
