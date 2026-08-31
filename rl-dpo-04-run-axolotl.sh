#!/bin/bash
# rl-dpo-04: DPO 학습 (full 모드)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/dpo-full-config/qwen2.5-1.5b-rl-dpo.yaml
LOG=logs/rl-dpo.log
OUT_DIR=./data/dpo-full-out/adapter
DATA_IN="data/dpo-full-in/train_rl-dpo.jsonl"

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" -- do_train

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"
