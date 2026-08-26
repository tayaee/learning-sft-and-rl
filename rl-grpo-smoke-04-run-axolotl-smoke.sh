#!/bin/bash
# rl-grpo-04-run-axolotl-smoke.sh — rl-grpo-04-run-axolotl.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-grpo-04-run-axolotl.sh" smoke "$@"
