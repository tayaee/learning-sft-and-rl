#!/bin/bash
# rl-orpo-11-upload-to-hf-full.sh — rl-orpo-11-upload-to-hf.sh 의 full 모드 래퍼
exec "$(dirname "$0")/rl-orpo-11-upload-to-hf.sh" full "$@"
