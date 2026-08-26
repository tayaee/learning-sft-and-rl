#!/bin/bash
# rl-orpo-08: SFT vs ORPO 정량 비교 — 휴리스틱 reward 평균 점수
#   $1 = smoke | full (반드시 지정; 같은 모드의 SFT/ORPO merge 모델끼리 비교)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  N=10
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
  ORPO_MODEL=./outputs/qwen2.5-1.5b-rl-orpo-smoke-merge/merged
else
  N=50
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
  ORPO_MODEL=./outputs/qwen2.5-1.5b-rl-orpo-merge/merged
fi
OUT="outputs/eval_results/orpo-reward-$MODE.jsonl"

echo "input: $SFT_MODEL, $ORPO_MODEL, reward_fn.py"
echo "output: $OUT"

mkdir -p outputs/eval_results
set -x
uv run python eval_orpo_reward.py --mode "$MODE" --num-prompts "$N" \
  --out "$OUT"
set +x

echo "input: $SFT_MODEL, $ORPO_MODEL, reward_fn.py"
echo "output: $OUT"
