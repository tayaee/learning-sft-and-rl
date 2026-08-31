#!/bin/bash
# rl-dpo-03: DPO config 검토
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  CFG="data/dpo-mini-config/qwen2.5-1.5b-rl-dpo-mini.yaml"
else
  CFG="data/dpo-full-config/qwen2.5-1.5b-rl-dpo.yaml"
fi

echo "input: $CFG"
echo "output: (stdout)"

set -x
cat "$CFG"
set +x

echo "input: $CFG"
echo "output: (stdout)"
