#!/bin/bash
# rl-grpo-04: GRPO 학습 (full 모드)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

CFG=data/grpo-full-config/qwen2.5-1.5b-rl-grpo.yaml
LOG=logs/rl-grpo.log
OUT_DIR=./data/grpo-full-out/adapter
DATA_IN="data/grpo-full-in/sample_rl-grpo.jsonl"

echo "input: $CFG, $DATA_IN, reward_fn.py"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" "reward_fn.py" -- do_train

echo "input: $CFG, $DATA_IN, reward_fn.py"
echo "output: $OUT_DIR, $LOG"
