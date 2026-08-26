#!/bin/bash
# rl-dpo-04: DPO 학습 (smoke / full 선택 — 반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-rl-dpo-smoke.yaml
  LOG=logs/rl-dpo-smoke.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-dpo-smoke
else
  CFG=configs/qwen2.5-1.5b-rl-dpo.yaml
  LOG=logs/rl-dpo.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-dpo
fi

echo "input: $CFG, data/$MODE/train_rl-dpo.jsonl"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs
set -x
uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
set +x

echo "input: $CFG, data/$MODE/train_rl-dpo.jsonl"
echo "output: $OUT_DIR, $LOG"
