#!/bin/bash -x
# rl-grpo-08: 4 모델 비교 — 동일 질문(피타고라스 정리)을 모든 모델에 던져 정성 비교
#   $1 = smoke | full (반드시 지정; query_sft/query_rl_dpo/query_rl_grpo 의 merge 모델 선택)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

Q="피타고라스 정리를 증명하시오."
uv run query_base.py       "$Q"
uv run query_sft.py --mode "$MODE" "$Q"
uv run query_rl_dpo.py --mode "$MODE"     "$Q"
uv run query_rl_grpo.py --mode "$MODE"    "$Q"
