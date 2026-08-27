#!/bin/bash
# rl-dpo-01: DPO 선호 데이터 생성 (smoke / full 선택 — 반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  N=20
  K=2
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
else
  N=1000
  K=4
  SFT_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
fi

OUT="data/$MODE/train_rl-dpo.jsonl"
SAMPLE="data/$MODE/sample_rl-dpo.jsonl"

echo "input: $SFT_MODEL, Qwen/Qwen2.5-1.5B-Instruct"
echo "output: $OUT, $SAMPLE"

if [ ! -d "$SFT_MODEL" ]; then
  echo "ERROR: $SFT_MODEL 가 없습니다. 먼저 sft 학습+merge 를 --mode $MODE 로 완료하세요." >&2
  exit 1
fi

ensure_train_jsonl || exit 1

mkdir -p "data/$MODE" logs

_make "$OUT" "$SFT_MODEL" -- \
  uv run python make_rl_dpo_data.py \
    --sft-model "$SFT_MODEL" \
    --base-model Qwen/Qwen2.5-1.5B-Instruct \
    --num-prompts "$N" \
    --samples-per-prompt "$K" \
    --out "$OUT" \
    --sample-out "$SAMPLE"

echo "input: $SFT_MODEL, Qwen/Qwen2.5-1.5B-Instruct"
echo "output: $OUT, $SAMPLE"
