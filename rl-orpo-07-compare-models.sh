#!/bin/bash
# rl-orpo-07: SFT vs ORPO 정성 비교 (동일 질문 side-by-side)
#   $1 = smoke | full (반드시 지정; 같은 모드의 SFT merge 모델과 비교)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
  ORPO_MODEL=./outputs/qwen2.5-1.5b-rl-orpo-smoke-merge/merged
else
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
  ORPO_MODEL=./outputs/qwen2.5-1.5b-rl-orpo-merge/merged
fi

echo "input: $SFT_MODEL, $ORPO_MODEL"
echo "output: (stdout)"

Q="피타고라스 정리를 증명하시오."

echo "===== SFT ($MODE) ====="
set -x
uv run query_sft.py --mode "$MODE" "$Q"
set +x
echo "===== ORPO ($MODE) ====="
set -x
uv run query_rl_orpo.py --mode "$MODE" "$Q"
set +x

echo "input: $SFT_MODEL, $ORPO_MODEL"
echo "output: (stdout)"
