#!/bin/bash
# sft-05: SFT config 검토
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-full}" "$0" "$@") || exit 1

if [ "$MODE" = "smoke" ]; then
  CFG="configs/qwen2.5-1.5b-sft-smoke.yaml"
else
  CFG="configs/qwen2.5-1.5b-sft.yaml"
fi

echo "input: $CFG"
echo "output: (stdout)"

set -x
cat "$CFG"
set +x

echo "input: $CFG"
echo "output: (stdout)"
