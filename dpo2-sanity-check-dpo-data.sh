#!/bin/bash -x
# 같은 prompt 에 대한 chosen vs rejected 비교
head -1 data/sample_dpo.jsonl | uv run python -c "
import json, sys
d = json.loads(sys.stdin.read())
print('=== PROMPT ===')
print(d['prompt'][:200])
print('\n=== CHOSEN ===')
print(d['chosen'][:400])
print('\n=== REJECTED ===')
print(d['rejected'][:400])
"
