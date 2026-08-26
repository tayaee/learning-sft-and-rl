#!/bin/bash
# rl-dpo-07-test-model-full.sh — rl-dpo-07-test-model.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-07-test-model.sh" full "$@"
