#!/bin/bash
# rl-dpo-09-lm-eval-rl-dpo-full.sh — rl-dpo-09-lm-eval-rl-dpo.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-dpo-09-lm-eval-rl-dpo.sh" full "$@"
