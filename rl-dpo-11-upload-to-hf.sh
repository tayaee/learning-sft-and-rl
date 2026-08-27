#!/bin/bash
# rl-dpo-11: HF Hub 업로드 (DPO 평가 완료 후)
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-full}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  SRC=./outputs/qwen2.5-1.5b-rl-dpo-smoke-merge/merged
  REPO=tayaee/Qwen2.5-1.5B-Korean-DPO-smoke
else
  SRC=./outputs/qwen2.5-1.5b-rl-dpo-merge/merged
  REPO=tayaee/Qwen2.5-1.5B-Korean-DPO
fi

echo "input: $SRC"
echo "output: Hugging Face Hub ($REPO)"

if [ ! -d "$SRC" ]; then
  echo "ERROR: $SRC 가 없습니다. 먼저 rl-dpo-04 + rl-dpo-06 을 --mode $MODE 로 실행하세요." >&2
  exit 1
fi

set -x
uv run hf auth login --token $HF_TOKEN
uv run hf auth whoami
uv run hf upload "$REPO" "$SRC" . --commit-message "Upload Qwen2.5-1.5B Korean DPO model ($MODE)"
set +x

echo "input: $SRC"
echo "output: Hugging Face Hub ($REPO)"
