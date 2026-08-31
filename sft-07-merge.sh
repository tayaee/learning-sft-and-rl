#!/bin/bash
# sft-07: LoRA merge (train 은 어댑터만 저장 → merge 별도 필요)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-full}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  CFG=data/sft-mini-config/qwen2.5-1.5b-sft-mini.yaml
  ADAPTER=./data/sft-mini-out/adapter
  OUT=./data/sft-mini-out
else
  CFG=data/sft-full-config/qwen2.5-1.5b-sft.yaml
  ADAPTER=./data/sft-full-out/adapter
  OUT=./data/sft-full-out
fi

echo "input: $CFG, $ADAPTER"
echo "output: $OUT/merged"

do_merge() {
  uv run axolotl merge-lora "$CFG" \
    --lora-model-dir "$ADAPTER" \
    --output-dir    "$OUT"
  ls "$OUT"/merged/
}

_make "$OUT/merged" "$ADAPTER" "$CFG" -- do_merge

echo "input: $CFG, $ADAPTER"
echo "output: $OUT/merged"
