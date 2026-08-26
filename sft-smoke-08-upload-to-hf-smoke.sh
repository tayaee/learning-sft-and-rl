#!/bin/bash
# sft-08-upload-to-hf-smoke.sh — sft-08-upload-to-hf.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-08-upload-to-hf.sh" smoke "$@"
