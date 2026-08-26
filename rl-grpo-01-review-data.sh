#!/bin/bash -x
# rl-grpo-01: GRPO 학습 데이터 검증
#   $1 = smoke | full (반드시 지정)
# - data/<mode>/sample_rl-grpo.jsonl: GRPO 형식 ({"prompt": "..."})
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
SAMPLE="data/$MODE/sample_rl-grpo.jsonl"

if [ ! -f "$SAMPLE" ]; then
  echo "ERROR: $SAMPLE 가 없습니다. 파일을 준비하거나 다른 모드를 선택하세요." >&2
  exit 1
fi

wc -l "$SAMPLE"
head -1 "$SAMPLE" | uv run python -m json.tool | head -10
