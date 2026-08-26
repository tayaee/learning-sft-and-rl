#!/bin/bash
# rl-orpo-04-run-axolotl-full.sh — rl-orpo-04-run-axolotl.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-orpo-04-run-axolotl.sh" full "$@"
