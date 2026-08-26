#!/bin/bash
# sft-09-vllm-serve-smoke.sh — sft-09-vllm-serve.sh 의 smoke 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-09-vllm-serve.sh" smoke "$@"
