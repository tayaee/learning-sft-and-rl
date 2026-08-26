#!/bin/bash -x
# rl-grpo-07: GRPO merge 모델 다른 프롬프트로 검증 (grpo-05 변형; merge 후 실행)
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
uv run query_rl_grpo.py --mode "$MODE" "피보나치 수열의 일반항을 유도하시오."
