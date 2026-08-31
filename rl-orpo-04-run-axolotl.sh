#!/bin/bash
# rl-orpo-04: ORPO 학습 (full 모드)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/orpo-full-config/qwen2.5-1.5b-rl-orpo.yaml
LOG=logs/rl-orpo.log
OUT_DIR=./data/orpo-full-out/adapter
DATA_IN="data/orpo-full-in/train_rl-orpo.jsonl"

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" -- do_train

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"
