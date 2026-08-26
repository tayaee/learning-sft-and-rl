#!/bin/bash
# rl-orpo-08-reward-eval-full.sh — rl-orpo-08-reward-eval.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-orpo-08-reward-eval.sh" full "$@"
