#!/bin/bash
# rl-grpo-04 mini: GRPO mini 학습
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/grpo-mini-config/qwen2.5-1.5b-rl-grpo-mini.yaml
LOG=logs/rl-grpo-mini.log
OUT_DIR=./data/grpo-mini-out/adapter
DATA_IN="data/grpo-mini-in/sample_rl-grpo.jsonl"

echo "input: $CFG, $DATA_IN, reward_fn.py"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" "reward_fn.py" -- do_train

echo "input: $CFG, $DATA_IN, reward_fn.py"
echo "output: $OUT_DIR, $LOG"
