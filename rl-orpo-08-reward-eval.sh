#!/bin/bash -x
# rl-orpo-08: SFT vs ORPO 정량 비교 — 휴리스틱 reward 평균 점수
#   $1 = smoke | full (반드시 지정; 같은 모드의 SFT/ORPO merge 모델끼리 비교)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then N=10; else N=50; fi
mkdir -p outputs/eval_results
uv run python eval_orpo_reward.py --mode "$MODE" --num-prompts "$N" \
  --out outputs/eval_results/orpo-reward-$MODE.jsonl
