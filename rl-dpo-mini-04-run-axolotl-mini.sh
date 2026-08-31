#!/bin/bash
# rl-dpo-04 mini: DPO mini 학습
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/dpo-mini-config/qwen2.5-1.5b-rl-dpo-mini.yaml
LOG=logs/rl-dpo-mini.log
OUT_DIR=./data/dpo-mini-out/adapter
DATA_IN="data/dpo-mini-in/train_rl-dpo.jsonl"

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" -- do_train

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"
