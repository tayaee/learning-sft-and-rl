#!/bin/bash
# rl-grpo-11-upload-to-hf-smoke.sh — rl-grpo-11-upload-to-hf.sh 의 smoke 모드 래퍼
exec "$(dirname "$0")/rl-grpo-11-upload-to-hf.sh" smoke "$@"
