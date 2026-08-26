#!/bin/bash
# rl-grpo-04: GRPO 학습 (smoke / full 선택 — 반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-rl-grpo-smoke.yaml
  LOG=logs/rl-grpo-smoke.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-grpo-smoke
else
  CFG=configs/qwen2.5-1.5b-rl-grpo.yaml
  LOG=logs/rl-grpo.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-grpo
fi

echo "input: $CFG, data/$MODE/sample_rl-grpo.jsonl, reward_fn.py"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs
set -x
uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
set +x

echo "input: $CFG, data/$MODE/sample_rl-grpo.jsonl, reward_fn.py"
echo "output: $OUT_DIR, $LOG"
