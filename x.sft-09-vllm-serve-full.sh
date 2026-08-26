#!/bin/bash
# sft-09-vllm-serve-full.sh — sft-09-vllm-serve.sh 의 full 모드 래퍼 (인자는 그대로 전달)
exec "$(dirname "$0")/sft-09-vllm-serve.sh" full "$@"
