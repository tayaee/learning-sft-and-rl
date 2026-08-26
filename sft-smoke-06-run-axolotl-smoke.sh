#!/bin/bash
# sft-06-run-axolotl-smoke.sh — sft-06-run-axolotl.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-06-run-axolotl.sh" smoke "$@"
