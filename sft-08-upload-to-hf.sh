#!/bin/bash
# sft-08: HF Hub 업로드 (merge 완료 후)
#   $1 = smoke | full (생략 시 full 기본) — 모드별 로컬 merge 디렉터리와 Hub repo 가 분리됨
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-full}" "$0") || exit 1

if [ "$MODE" = "smoke" ]; then
  SRC=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
  REPO=tayaee/Qwen2.5-1.5B-Instruct-ko-Reasoning-alpha-smoke
else
  SRC=./outputs/qwen2.5-1.5b-sft-merge/merged
  REPO=tayaee/Qwen2.5-1.5B-Instruct-ko-Reasoning-alpha
fi

echo "input: $SRC"
echo "output: Hugging Face Hub ($REPO)"

if [ ! -d "$SRC" ]; then
  echo "ERROR: $SRC 가 없습니다. 먼저 sft-06 + sft-07 을 --mode $MODE 로 실행하세요." >&2
  exit 1
fi

set -x
uv run hf auth login --token $HF_TOKEN
uv run hf auth whoami
uv run hf upload "$REPO" "$SRC" . --commit-message "alpha: SFT 1 epoch on 50k Korean CoT ($MODE)"
set +x

echo "input: $SRC"
echo "output: Hugging Face Hub ($REPO)"
