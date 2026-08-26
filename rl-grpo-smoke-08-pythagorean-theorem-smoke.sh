#!/bin/bash
# rl-grpo-08-pythagorean-theorem-smoke.sh — rl-grpo-08-pythagorean-theorem.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-grpo-08-pythagorean-theorem.sh" smoke "$@"
