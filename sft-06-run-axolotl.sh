#!/bin/bash
# sft-06: SFT 학습 (smoke / full 선택 — 생략 시 full 기본)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-full}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG=configs/qwen2.5-1.5b-sft-smoke.yaml
  LOG=logs/sft-smoke.log
  OUT_DIR=./outputs/qwen2.5-1.5b-sft-smoke
  IN_DATA="data/smoke/train-sft.jsonl (or train.jsonl)"
  OUT_EXTRA=", data/smoke/train-sft.jsonl"
  echo "input: $CFG, $IN_DATA"
  echo "output: $OUT_DIR, $LOG$OUT_EXTRA"
  # smoke 데이터가 없으면 train.jsonl 앞부분 200건으로 생성 (smoke 전용 디렉터리)
  if [ ! -f data/smoke/train-sft.jsonl ]; then
    mkdir -p data/smoke
    head -n 200 train.jsonl > data/smoke/train-sft.jsonl
    wc -l data/smoke/train-sft.jsonl
  fi
else
  CFG=configs/qwen2.5-1.5b-sft.yaml
  LOG=logs/sft.log
  OUT_DIR=./outputs/qwen2.5-1.5b-sft
  IN_DATA="train.jsonl"
  OUT_EXTRA=""
  echo "input: $CFG, $IN_DATA"
  echo "output: $OUT_DIR, $LOG"
fi

mkdir -p logs
set -x
uv run axolotl train "$CFG" 2>&1 | tee "$LOG"
set +x

echo "input: $CFG, $IN_DATA"
echo "output: $OUT_DIR, $LOG$OUT_EXTRA"
