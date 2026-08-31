#!/bin/bash
# rl-grpo-05: GRPO merge 모델 단일 추론 테스트 (merge 후 실행)
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
uv run query_rl_grpo.py --mode "$MODE" "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
set +x

echo "input: $MODEL"
echo "output: (stdout)"
