#!/bin/bash -x
# rl-grpo-03: GRPO config 검증
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  cat configs/qwen2.5-1.5b-rl-grpo-smoke.yaml    # data/smoke/ 사용
else
  cat configs/qwen2.5-1.5b-rl-grpo.yaml          # data/full/ 사용
fi
