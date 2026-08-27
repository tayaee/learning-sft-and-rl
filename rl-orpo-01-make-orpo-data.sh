#!/bin/bash
# rl-orpo-01: ORPO 선호 데이터 생성 (smoke / full 선택 — 반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  N=20
else
  N=1000
fi

FROM_DPO="data/$MODE/train_rl-dpo.jsonl"
OUT="data/$MODE/train_rl-orpo.jsonl"

echo "input: $FROM_DPO"
echo "output: $OUT"

if [ ! -f "$FROM_DPO" ]; then
  echo "ERROR: $FROM_DPO 가 없습니다. 먼저 ./rl-dpo-01-make-rl-dpo-data.sh $MODE 실행하세요." >&2
  exit 1
fi

mkdir -p "data/$MODE"

_make "$OUT" "$FROM_DPO" -- \
  uv run python make_rl_orpo_data.py \
    --from-dpo "$FROM_DPO" \
    --num-prompts "$N" \
    --out "$OUT"

echo "input: $FROM_DPO"
echo "output: $OUT"
