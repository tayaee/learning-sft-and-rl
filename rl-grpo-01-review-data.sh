#!/bin/bash -x
# grpo1: GRPO 학습 데이터 검증
# - data/sample_rl-grpo.jsonl: 20 prompts, GRPO 형식 ({"prompt": "..."})
wc -l data/sample_rl-grpo.jsonl
head -1 data/sample_rl-grpo.jsonl | uv run python -m json.tool | head -10