#!/bin/bash
# sft-12-eval-compare-smoke.sh — sft-12-eval-compare.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-12-eval-compare.sh" smoke "$@"
