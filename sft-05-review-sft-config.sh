#!/bin/bash -x
# sft-05: SFT config 검토
#   $1 = smoke | full (생략 시 full 기본)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-full}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  more configs/qwen2.5-1.5b-sft-smoke.yaml    # data/smoke/train-sft.jsonl 사용
else
  more configs/qwen2.5-1.5b-sft.yaml          # 루트 train.jsonl 사용
fi
