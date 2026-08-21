#!/bin/bash -x
# grpo2: GRPO reward 함수 검증
# - reward_fn.py: 4개 휴리스틱 보상 (format, structure, length, keyword)
uv run python -c "import reward_fn; print('reward functions:', [f for f in dir(reward_fn) if f.endswith('_reward')])"
cat reward_fn.py