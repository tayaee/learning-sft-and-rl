#!/bin/bash
# sft-13-upload-to-hf-full.sh — sft-13-upload-to-hf.sh 의 full 모드 래퍼
exec "$(dirname "$0")/sft-13-upload-to-hf.sh" full "$@"
