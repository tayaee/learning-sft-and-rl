#!/bin/bash -x
# dpo9: DPO 모델 lm-eval (한국어 + 영어 tasks)
uv run lm_eval \
  --model hf \
  --model_args pretrained=./outputs/qwen2.5-1.5b-rl-dpo-merge/merged,dtype=bfloat16 \
  --tasks kobest_hellaswag,kobest_copa,kmmlu,hellaswag,arc_easy,piqa,winogrande \
  --apply_chat_template \
  --batch_size 8 \
  --limit 100 \
  --output_path ./outputs/lm_eval_results/rl-dpo