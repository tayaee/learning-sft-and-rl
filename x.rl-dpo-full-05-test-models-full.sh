#!/bin/bash
# rl-dpo-05-test-models-full.sh — rl-dpo-05-test-models.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-05-test-models.sh" full "$@"
