#!/bin/bash
# rl-grpo-06-merge-full.sh — rl-grpo-06-merge.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-grpo-06-merge.sh" full "$@"
