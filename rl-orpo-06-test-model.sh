#!/bin/bash -x
# rl-orpo-06: ORPO 모델 추론 테스트
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
uv run query_rl_orpo.py --mode "$MODE" "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
