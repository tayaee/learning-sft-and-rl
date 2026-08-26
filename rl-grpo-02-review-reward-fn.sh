#!/bin/bash
# grpo2: GRPO reward 함수 검증
# - reward_fn.py: 4개 휴리스틱 보상 (format, structure, length, keyword)
echo "input: reward_fn.py"
echo "output: (stdout)"

set -x
uv run python -c "import reward_fn; print('reward functions:', [f for f in dir(reward_fn) if f.endswith('_reward')])"
cat reward_fn.py
set +x

echo "input: reward_fn.py"
echo "output: (stdout)"
