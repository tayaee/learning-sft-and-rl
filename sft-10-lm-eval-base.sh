#!/bin/bash -x
# sft-10: BASE 모델 lm-eval (한국어 + 영어 tasks)
# axolotl 래퍼는 --limit 미지원 → lm_eval 직접 호출
# --limit 으로 빠른 sanity check (각 task 100 examples)
# 전체 결과 필요시 LIMIT 아래 줄의 주석 해제
uv run lm_eval \
  --model hf \
  --model_args pretrained=Qwen/Qwen2.5-1.5B-Instruct,dtype=bfloat16 \
  --tasks kobest_hellaswag,kobest_copa,kmmlu,hellaswag,arc_easy,piqa,winogrande \
  --apply_chat_template \
  --batch_size 8 \
  --limit 100 \
  --output_path ./outputs/lm_eval_results/base