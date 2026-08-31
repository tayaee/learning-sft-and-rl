#!/bin/bash
# rl-dpo-06: LoRA merge (train 은 어댑터만 저장 → merge 별도 필요)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  CFG=data/dpo-mini-config/qwen2.5-1.5b-rl-dpo-mini.yaml
  ADAPTER=./data/dpo-mini-out/adapter
  OUT=./data/dpo-mini-out
else
  CFG=data/dpo-full-config/qwen2.5-1.5b-rl-dpo.yaml
  ADAPTER=./data/dpo-full-out/adapter
  OUT=./data/dpo-full-out
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
