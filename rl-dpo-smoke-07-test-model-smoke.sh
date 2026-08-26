#!/bin/bash
# rl-dpo-07-test-model-smoke.sh — rl-dpo-07-test-model.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-07-test-model.sh" smoke "$@"
