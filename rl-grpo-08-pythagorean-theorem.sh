#!/bin/bash -x
# grpo8: 4 모델 비교 — 동일 질문(피타고라스 정리)을 모든 모델에 던져 정성 비교
Q="피타고라스 정리를 증명하시오."
uv run query-base.py       "$Q"
uv run query-sft.py        "$Q"
uv run query-rl-dpo.py     "$Q"
uv run query-rl-grpo.py    "$Q"