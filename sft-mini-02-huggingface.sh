#!/usr/bin/env bash
# sft-02-huggingface.sh: Hugging Face CLI 로그인
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
set -euo pipefail

echo "input: (interactive token)"
echo "output: ~/.cache/huggingface/token"

set -x
hf auth login
set +x

echo "input: (interactive token)"
echo "output: ~/.cache/huggingface/token"
