#!/bin/bash
# rl-grpo-06: LoRA merge (train 은 어댑터만 저장 → merge 별도 필요)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "mini" ]; then
  CFG=data/grpo-mini-config/qwen2.5-1.5b-rl-grpo-mini.yaml
  ADAPTER=./data/grpo-mini-out/adapter
  OUT=./data/grpo-mini-out
else
  CFG=data/grpo-full-config/qwen2.5-1.5b-rl-grpo.yaml
  ADAPTER=./data/grpo-full-out/adapter
  OUT=./data/grpo-full-out
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
