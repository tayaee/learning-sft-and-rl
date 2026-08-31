#!/bin/bash
# grpo2: GRPO reward 함수 검증
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

echo "input: reward_fn.py"
echo "output: (stdout)"

set -x
uv run python -c "import reward_fn; print('reward functions:', [f for f in dir(reward_fn) if f.endswith('_reward')])"
cat reward_fn.py
set +x

echo "input: reward_fn.py"
echo "output: (stdout)"
