#!/bin/bash -x
# rl-dpo-05: DPO merge 모델 단일 추론 테스트 (merge 후 실행)
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
uv run query_rl_dpo.py --mode "$MODE" "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
