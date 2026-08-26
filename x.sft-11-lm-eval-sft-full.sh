#!/bin/bash
# sft-11-lm-eval-sft-full.sh — sft-11-lm-eval-sft.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-11-lm-eval-sft.sh" full "$@"
