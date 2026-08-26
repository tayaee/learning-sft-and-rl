#!/bin/bash
# rl-orpo-09: ORPO 모델 lm-eval (한국어 + 영어 tasks, sanity limit 100)
#   $1 = smoke | full (반드시 지정) — 모델 경로와 결과 저장 경로가 모드별로 분리됨
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  MODEL=./outputs/qwen2.5-1.5b-rl-orpo-smoke-merge/merged
else
  MODEL=./outputs/qwen2.5-1.5b-rl-orpo-merge/merged
fi

OUT=./outputs/lm_eval_results/rl-orpo-$MODE

echo "input: $MODEL"
echo "output: $OUT"

if [ ! -d "$MODEL" ]; then
  echo "ERROR: $MODEL 가 없습니다. 먼저 orpo 학습+merge 를 --mode $MODE 로 완료하세요." >&2
  exit 1
fi

set -x
uv run lm_eval \
  --model hf \
  --model_args pretrained="$MODEL",dtype=bfloat16 \
  --tasks kobest_hellaswag,kobest_copa,kmmlu,hellaswag,arc_easy,piqa,winogrande \
  --apply_chat_template \
  --batch_size 8 \
  --limit 100 \
  --output_path "$OUT"
set +x

echo "input: $MODEL"
echo "output: $OUT"
