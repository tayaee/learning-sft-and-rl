#!/bin/bash
# sft-06-run-axolotl-full.sh — sft-06-run-axolotl.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-06-run-axolotl.sh" full "$@"
