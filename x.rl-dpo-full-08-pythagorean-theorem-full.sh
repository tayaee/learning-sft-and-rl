#!/bin/bash
# rl-dpo-08-pythagorean-theorem-full.sh — rl-dpo-08-pythagorean-theorem.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-08-pythagorean-theorem.sh" full "$@"
