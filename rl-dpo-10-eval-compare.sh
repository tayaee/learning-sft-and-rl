#!/bin/bash
# rl-dpo-10: 이전 모델(SFT merge) vs 새 모델(DPO merge) 비교 평가 — 2개 평가 + 비교표
#   $1 = smoke | full (반드시 지정)
#   평가 ① general : tinyArc,tinyHellaswag,tinyMMLU,tinyWinogrande (loglikelihood, 수 분)
#   평가 ② korean  : kobest_copa,kobest_hellaswag                 (loglikelihood, 수 분)
source "$(dirname "$0")/scripts_common.sh"
MODE=$(require_mode "${1:-}" "$0") || exit 1

GENERAL_TASKS=tinyArc,tinyHellaswag,tinyMMLU,tinyWinogrande
KOREAN_TASKS=kobest_copa,kobest_hellaswag

if [ "$MODE" = "smoke" ]; then
  PREV_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged   # 이전 모델 = SFT(smoke)
  NEW_MODEL=./outputs/qwen2.5-1.5b-rl-dpo-smoke-merge/merged
  PREV_LABEL="SFT(smoke)"
  NEW_LABEL="DPO(smoke)"
else
  PREV_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged         # 이전 모델 = SFT(full)
  NEW_MODEL=./outputs/qwen2.5-1.5b-rl-dpo-merge/merged
  PREV_LABEL="SFT(full)"
  NEW_LABEL="DPO(full)"
fi
OUT=outputs/lm_eval_results/rl-dpo-$MODE

echo "input: $PREV_MODEL, $NEW_MODEL"
echo "output: $OUT, $OUT/comparison-table.md"

[ -d "$PREV_MODEL" ] || { echo "ERROR: $PREV_MODEL 없음 — 먼저 sft-06 + sft-07 을 --mode $MODE 로 실행하세요." >&2; exit 1; }
[ -d "$NEW_MODEL" ] || { echo "ERROR: $NEW_MODEL 없음 — 먼저 rl-dpo-04 + rl-dpo-06 을 --mode $MODE 로 실행하세요." >&2; exit 1; }

run_eval () {  # $1=model  $2=tasks  $3=outdir
  mkdir -p "$OUT"
  uv run lm_eval \
    --model hf \
    --model_args pretrained="$1",dtype=bfloat16 \
    --tasks "$2" \
    --apply_chat_template \
    --batch_size 8 \
    --output_path "$OUT/$3"
}

set -x
run_eval "$PREV_MODEL" "$GENERAL_TASKS" prev-general
run_eval "$NEW_MODEL"  "$GENERAL_TASKS" new-general
run_eval "$PREV_MODEL" "$KOREAN_TASKS"  prev-korean
run_eval "$NEW_MODEL"  "$KOREAN_TASKS"  new-korean

uv run python eval_compare_table.py "$OUT" \
  --labels "prev=$PREV_LABEL,new=$NEW_LABEL" | tee "$OUT/comparison-table.md"
set +x

echo "input: $PREV_MODEL, $NEW_MODEL"
echo "output: $OUT, $OUT/comparison-table.md"
