#!/bin/bash
# sft-09: vllm 로컬 serve (merge 완료 후)
#   $1 = smoke | full (생략 시 full 기본) — 모드별 merge 디렉터리를 서빙
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-full}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
else
  MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
fi

echo "input: $MODEL"
echo "output: vLLM Server (http://0.0.0.0:8000)"

if [ ! -d "$MODEL" ]; then
  echo "ERROR: $MODEL 가 없습니다. 먼저 sft-06 + sft-07 을 --mode $MODE 로 실행하세요." >&2
  exit 1
fi

set -x
uvx vllm serve "$MODEL" \
  --host 0.0.0.0 \
  --port 8000 \
  --dtype bfloat16 \
  --max-model-len 8192
set +x

echo "input: $MODEL"
echo "output: vLLM Server (http://0.0.0.0:8000)"
