#!/bin/bash
# rl-orpo-05: LoRA merge (train 은 어댑터만 저장 → merge 별도 필요)
#   $1 = smoke | full (반드시 지정; rl-orpo-04 와 동일 모드 사용)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-rl-orpo-smoke.yaml
  ADAPTER=./outputs/qwen2.5-1.5b-rl-orpo-smoke
  OUT=./outputs/qwen2.5-1.5b-rl-orpo-smoke-merge
else
  CFG=configs/qwen2.5-1.5b-rl-orpo.yaml
  ADAPTER=./outputs/qwen2.5-1.5b-rl-orpo
  OUT=./outputs/qwen2.5-1.5b-rl-orpo-merge
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
