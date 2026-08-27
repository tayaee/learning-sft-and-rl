#!/bin/bash
# sft-smoke-13-upload-to-hf-smoke.sh — sft-13-upload-to-hf.sh 의 smoke 모드 래퍼
exec "$(dirname "$0")/sft-13-upload-to-hf.sh" smoke "$@"
