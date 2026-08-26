#!/bin/bash
# rl-dpo-05-test-models-smoke.sh — rl-dpo-05-test-models.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-05-test-models.sh" smoke "$@"
