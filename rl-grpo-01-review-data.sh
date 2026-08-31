#!/bin/bash
# rl-grpo-01: GRPO 학습 데이터 검증
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-}" "$0" "$@") || exit 1
SAMPLE="data/grpo-$MODE-out/sample_rl-grpo.jsonl"

echo "input: $SAMPLE"
echo "output: (stdout)"

if [ ! -f "$SAMPLE" ]; then
  echo "ERROR: $SAMPLE 가 없습니다. 파일을 준비하거나 다른 모드를 선택하세요." >&2
  exit 1
fi

set -x
wc -l "$SAMPLE"
head -1 "$SAMPLE" | uv run python -m json.tool | head -10
set +x

echo "input: $SAMPLE"
echo "output: (stdout)"
