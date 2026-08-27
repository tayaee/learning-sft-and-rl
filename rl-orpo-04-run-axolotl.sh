#!/bin/bash
# rl-orpo-04: ORPO 학습 (smoke / full 선택 — 반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-rl-orpo-smoke.yaml
  LOG=logs/rl-orpo-smoke.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-orpo-smoke
else
  CFG=configs/qwen2.5-1.5b-rl-orpo.yaml
  LOG=logs/rl-orpo.log
  OUT_DIR=./outputs/qwen2.5-1.5b-rl-orpo
fi
DATA_IN="data/$MODE/train_rl-orpo.jsonl"

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"

mkdir -p logs

do_train() {
  uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
}

_make "$OUT_DIR" "$CFG" "$DATA_IN" -- do_train

echo "input: $CFG, $DATA_IN"
echo "output: $OUT_DIR, $LOG"
