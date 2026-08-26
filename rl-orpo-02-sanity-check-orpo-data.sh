#!/bin/bash
# rl-orpo-02: ORPO 데이터 sanity check — chosen vs rejected 눈으로 비교
#   $1 = smoke | full (반드시 지정)
# 데이터는 TRL conversational 용 메시지 리스트 포맷:
#   {"prompt": str, "chosen": [user, assistant], "rejected": [user, assistant]}
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1
DATA="data/$MODE/train_rl-orpo.jsonl"

if [ "$MODE" = "smoke" ]; then
  CFG="configs/qwen2.5-1.5b-rl-orpo-smoke.yaml"
else
  CFG="configs/qwen2.5-1.5b-rl-orpo.yaml"
fi

echo "input: $DATA, $CFG"
echo "output: (stdout)"

if [ ! -f "$DATA" ]; then
  echo "ERROR: $DATA 가 없습니다. 먼저 ./rl-orpo-01-make-orpo-data.sh $MODE 실행하세요." >&2
  exit 1
fi

set -x
head -1 "$DATA" | uv run python -c "
import json, sys
d = json.loads(sys.stdin.read())
print('=== PROMPT ===')
print(d['prompt'][:200])
print('\n=== CHOSEN (assistant) ===')
print(d['chosen'][-1]['content'][:400])
print('\n=== REJECTED (assistant) ===')
print(d['rejected'][-1]['content'][:400])
assert d['chosen'][0]['role'] == 'user' and d['chosen'][1]['role'] == 'assistant'
assert len(d['chosen']) == len(d['rejected']) == 2
print('\n[ok] message-list format valid')
"
wc -l "$DATA"
more "$CFG"
set +x

echo "input: $DATA, $CFG"
echo "output: (stdout)"
