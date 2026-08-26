#!/bin/bash -x
# rl-dpo-02: 같은 prompt 에 대한 chosen vs rejected 비교
#   $1 = smoke | full (반드시 지정)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
SAMPLE="data/$MODE/sample_rl-dpo.jsonl"

if [ ! -f "$SAMPLE" ]; then
  echo "ERROR: $SAMPLE 가 없습니다. 먼저 ./rl-dpo-01-make-rl-dpo-data.sh $MODE 실행하세요." >&2
  exit 1
fi

head -1 "$SAMPLE" | uv run python -c "
import json, sys
d = json.loads(sys.stdin.read())
print('=== PROMPT ===')
print(d['prompt'][:200])
print('\n=== CHOSEN ===')
print(d['chosen'][:400])
print('\n=== REJECTED ===')
print(d['rejected'][:400])
"
wc -l "$SAMPLE" "data/$MODE/train_rl-dpo.jsonl"
