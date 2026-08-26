#!/bin/bash
# rl-orpo-02-sanity-check-orpo-data-full.sh — rl-orpo-02-sanity-check-orpo-data.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/rl-orpo-02-sanity-check-orpo-data.sh" full "$@"
