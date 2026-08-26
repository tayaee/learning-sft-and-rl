#!/bin/bash
# sft-07: LoRA merge (train 은 어댑터만 저장 → merge 별도 필요)
#   $1 = smoke | full (생략 시 full 기본; sft-06 과 동일 모드 사용)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-full}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-sft-smoke.yaml
  ADAPTER=./outputs/qwen2.5-1.5b-sft-smoke
  OUT=./outputs/qwen2.5-1.5b-sft-smoke-merge
else
  CFG=configs/qwen2.5-1.5b-sft.yaml
  ADAPTER=./outputs/qwen2.5-1.5b-sft
  OUT=./outputs/qwen2.5-1.5b-sft-merge
fi

echo "input: $CFG, $ADAPTER"
echo "output: $OUT/merged"

set -x
uv run axolotl merge-lora "$CFG" \
  --lora-model-dir "$ADAPTER" \
  --output-dir    "$OUT"
set +x

ls "$OUT"/merged/

echo "input: $CFG, $ADAPTER"
echo "output: $OUT/merged"
