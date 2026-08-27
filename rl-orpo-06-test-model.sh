#!/bin/bash
# rl-orpo-06: ORPO 모델 추론 테스트
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  MODEL=./outputs/qwen2.5-1.5b-rl-orpo-smoke-merge/merged
else
  MODEL=./outputs/qwen2.5-1.5b-rl-orpo-merge/merged
fi

echo "input: $MODEL"
echo "output: (stdout)"

set -x
uv run query_rl_orpo.py --mode "$MODE" "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
set +x

echo "input: $MODEL"
echo "output: (stdout)"
