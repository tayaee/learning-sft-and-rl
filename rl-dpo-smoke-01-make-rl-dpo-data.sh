#!/bin/bash
# rl-dpo-01-make-rl-dpo-data-smoke.sh — rl-dpo-01-make-rl-dpo-data.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-01-make-rl-dpo-data.sh" smoke "$@"
