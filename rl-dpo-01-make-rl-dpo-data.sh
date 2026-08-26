#!/bin/bash -x
# rl-dpo-01: DPO 선호 데이터 생성 (smoke / full 선택 — 반드시 지정)
#   smoke → 50 prompts  → data/smoke/train_rl-dpo.jsonl (+ sample)
#   full  → 1000 prompts → data/full/train_rl-dpo.jsonl (+ sample)
# 각 모드의 SFT merge 모델을 사용하므로 모드 간 결과가 절대 섞이지 않는다.
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  N=50
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
else
  N=1000
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
fi

OUT="data/$MODE/train_rl-dpo.jsonl"
SAMPLE="data/$MODE/sample_rl-dpo.jsonl"

if [ ! -d "$SFT_MODEL" ]; then
  echo "ERROR: $SFT_MODEL 가 없습니다. 먼저 sft 학습+merge 를 --mode $MODE 로 완료하세요." >&2
  exit 1
fi

mkdir -p "data/$MODE" logs
uv run python make_rl_dpo_data.py \
  --sft-model "$SFT_MODEL" \
  --base-model Qwen/Qwen2.5-1.5B-Instruct \
  --num-prompts "$N" \
  --samples-per-prompt 4 \
  --out "$OUT" \
  --sample-out "$SAMPLE"
