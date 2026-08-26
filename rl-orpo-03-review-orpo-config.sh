#!/bin/bash -x
# rl-orpo-03: config 검토
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  more configs/qwen2.5-1.5b-rl-orpo-smoke.yaml    # data/smoke/ 사용
else
  more configs/qwen2.5-1.5b-rl-orpo.yaml          # data/full/ 사용
fi
