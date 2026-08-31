#!/bin/bash
# sft-06: SFT 학습 (full 모드)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/sft-full-config/qwen2.5-1.5b-sft.yaml
LOG=logs/sft.log
OUT_DIR=./data/sft-full-out/adapter
IN_DATA="train.jsonl"
OUT_EXTRA=""
echo "input: $CFG, $IN_DATA"
echo "output: $OUT_DIR, $LOG$OUT_EXTRA"
ensure_train_jsonl || exit 1

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$IN_DATA" -- do_train

echo "input: $CFG, $IN_DATA"
echo "output: $OUT_DIR, $LOG$OUT_EXTRA"
