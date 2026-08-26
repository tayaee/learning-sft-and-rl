#!/bin/bash
# rl-grpo-03: GRPO config 검증
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG="configs/qwen2.5-1.5b-rl-grpo-smoke.yaml"
else
  CFG="configs/qwen2.5-1.5b-rl-grpo.yaml"
fi

echo "input: $CFG"
echo "output: (stdout)"

set -x
cat "$CFG"
set +x

echo "input: $CFG"
echo "output: (stdout)"
