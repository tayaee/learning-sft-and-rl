#!/bin/bash -x
# rl-grpo-05: GRPO merge 모델 단일 추론 테스트
# 주의: 이 스크립트는 rl-grpo-06-merge.sh 이후에 성공 (merge된 모델 필요)
uv run query-rl-grpo.py "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."