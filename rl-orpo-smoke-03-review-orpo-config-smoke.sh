#!/bin/bash
# rl-orpo-03-review-orpo-config-smoke.sh — rl-orpo-03-review-orpo-config.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-orpo-03-review-orpo-config.sh" smoke "$@"
