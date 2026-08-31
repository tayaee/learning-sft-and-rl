#!/bin/bash
# rl-orpo-04 mini: ORPO mini 학습
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/orpo-mini-config/qwen2.5-1.5b-rl-orpo-mini.yaml
LOG=logs/rl-orpo-mini.log
OUT_DIR=./data/orpo-mini-out/adapter
DATA_IN="data/orpo-mini-in/train_rl-orpo.jsonl"

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" -- do_train

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"
