#!/bin/bash -x
# rl-orpo-01: ORPO 선호 데이터 생성 (smoke / full 선택 — 반드시 지정)
#   smoke → 20 pairs  → data/smoke/train_rl-orpo.jsonl  (data/smoke/train_rl-dpo.jsonl 재사용)
#   full  → 1000 pairs → data/full/train_rl-orpo.jsonl  (data/full/train_rl-dpo.jsonl 재사용)
# 기본은 DPO 데이터 재사용(빠름). 없으면 먼저 ./rl-dpo-01-make-rl-dpo-data.sh <mode> 실행.
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  N=20
else
  N=1000
fi

FROM_DPO="data/$MODE/train_rl-dpo.jsonl"
OUT="data/$MODE/train_rl-orpo.jsonl"

if [ ! -f "$FROM_DPO" ]; then
  echo "ERROR: $FROM_DPO 가 없습니다. 먼저 ./rl-dpo-01-make-rl-dpo-data.sh $MODE 실행하세요." >&2
  exit 1
fi

mkdir -p "data/$MODE"
uv run python make_rl_orpo_data.py \
  --from-dpo "$FROM_DPO" \
  --num-prompts "$N" \
  --out "$OUT"
