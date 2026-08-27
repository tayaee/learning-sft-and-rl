#!/bin/bash
# rl-dpo-08: 3 모델 비교 — 동일 질문(피타고라스 정리)을 base/SFT/DPO 에 던져 정성 비교
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
  DPO_MODEL=./outputs/qwen2.5-1.5b-rl-dpo-smoke-merge/merged
else
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
  DPO_MODEL=./outputs/qwen2.5-1.5b-rl-dpo-merge/merged
fi

echo "input: Qwen/Qwen2.5-1.5B-Instruct, $SFT_MODEL, $DPO_MODEL"
echo "output: (stdout)"

Q="피타고라스 정리를 증명하시오."
set -x
uv run query_base.py "$Q"
uv run query_sft.py --mode "$MODE" "$Q"
uv run query_rl_dpo.py --mode "$MODE" "$Q"
set +x

echo "input: Qwen/Qwen2.5-1.5B-Instruct, $SFT_MODEL, $DPO_MODEL"
echo "output: (stdout)"
