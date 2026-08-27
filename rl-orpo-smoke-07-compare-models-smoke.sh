#!/bin/bash
# rl-orpo-07-compare-models-smoke.sh — rl-orpo-07-compare-models.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-orpo-07-compare-models.sh" smoke "$@"
