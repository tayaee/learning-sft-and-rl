#!/bin/bash
# rl-grpo-07: GRPO merge 모델 다른 프롬프트로 검증 (grpo-05 변형; merge 후 실행)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  MODEL=./data/grpo-mini-out/merged
else
  MODEL=./data/grpo-full-out/merged
fi

echo "input: $MODEL"
echo "output: (stdout)"

set -x
uv run query_rl_grpo.py --mode "$MODE" "피보나치 수열의 일반항을 유도하시오."
set +x

echo "input: $MODEL"
echo "output: (stdout)"
