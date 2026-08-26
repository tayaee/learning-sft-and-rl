#!/bin/bash
# sft-12-eval-compare-full.sh — sft-12-eval-compare.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-12-eval-compare.sh" full "$@"
