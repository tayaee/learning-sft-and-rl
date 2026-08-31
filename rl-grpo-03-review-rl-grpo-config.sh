#!/bin/bash
# rl-grpo-03: GRPO config 검증
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  CFG="data/grpo-mini-config/qwen2.5-1.5b-rl-grpo-mini.yaml"
else
  CFG="data/grpo-full-config/qwen2.5-1.5b-rl-grpo.yaml"
fi

echo "input: $CFG"
echo "output: (stdout)"

set -x
cat "$CFG"
set +x

echo "input: $CFG"
echo "output: (stdout)"
