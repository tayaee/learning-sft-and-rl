#!/bin/bash
# rl-dpo-03-review-rl-dpo-config-full.sh — rl-dpo-03-review-rl-dpo-config.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-03-review-rl-dpo-config.sh" full "$@"
