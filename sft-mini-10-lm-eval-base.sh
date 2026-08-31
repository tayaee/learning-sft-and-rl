#!/bin/bash
# sft-10: BASE 모델 lm-eval (한국어 + 영어 tasks)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"

OUT=./outputs/lm_eval_results/base
MODEL=Qwen/Qwen2.5-1.5B-Instruct

echo "input: $MODEL"
echo "output: $OUT"

do_eval() {
  uv run lm_eval \
    --model hf \
    --model_args pretrained=$MODEL,dtype=bfloat16 \
    --tasks kobest_hellaswag,kobest_copa,kmmlu,hellaswag,arc_easy,piqa,winogrande \
    --apply_chat_template \
    --batch_size 8 \
    --limit 100 \
    --output_path "$OUT"
}

_make "$OUT" -- do_eval

echo "input: $MODEL"
echo "output: $OUT"
