#!/bin/bash
# sft-07-merge-smoke.sh — sft-07-merge.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-07-merge.sh" smoke "$@"
