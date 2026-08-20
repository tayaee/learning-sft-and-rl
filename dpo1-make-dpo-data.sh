#!/bin/bash -x
# 1000 for full, 50 for mini smoke test
uv run python make_dpo_data.py \
  --sft-model ./outputs/qwen2.5-1.5b-sft-merge/merged \
  --base-model Qwen/Qwen2.5-1.5B-Instruct \
  --num-prompts ${1:-50} \
  --samples-per-prompt 4 \
  --out data/train_dpo.jsonl \
  --sample-out data/sample_dpo.jsonl
