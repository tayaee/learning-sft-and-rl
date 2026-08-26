#!/bin/bash
# scripts_common.sh — smoke|full 모드 검증 공통 함수 (source 해서 사용)
# 사용법:
#   source scripts_common.sh
#   require_mode "$1" "$0"
require_mode() {
  local mode="${1:-}"
  local script="$2"
  if [ -z "$mode" ]; then
    echo "ERROR: 사용법: $script smoke|full  (smoke 또는 full 을 반드시 지정하세요)" >&2
    exit 1
  fi
  if [ "$mode" != "smoke" ] && [ "$mode" != "full" ]; then
    echo "ERROR: mode 는 'smoke' 또는 'full' 만 가능합니다 (입력값: $mode)" >&2
    exit 1
  fi
  echo "$mode"
}
