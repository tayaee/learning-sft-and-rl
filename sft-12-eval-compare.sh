#!/bin/bash
# sft-12: 이전 모델(Base) vs 새 모델(SFT merge) 비교 평가 — 2개 평가 + 비교표
source "$(dirname "$0")/scripts_common.sh"
parse_flags "$@"
MODE=$(require_mode "${1:-full}" "$0" "$@") || exit 1

GENERAL_TASKS=tinyArc,tinyHellaswag,tinyMMLU,tinyWinogrande
KOREAN_TASKS=kobest_copa,kobest_hellaswag

PREV_MODEL=Qwen/Qwen2.5-1.5B-Instruct          # 이전 모델 = base
if [ "$MODE" = "smoke" ]; then
  NEW_MODEL=./outputs/qwen2.5-1.5b-sft-smoke-merge/merged
  PREV_LABEL="Base"
  NEW_LABEL="SFT(smoke)"
else
  NEW_MODEL=./outputs/qwen2.5-1.5b-sft-merge/merged
  PREV_LABEL="Base"
  NEW_LABEL="SFT(full)"
fi
OUT=outputs/lm_eval_results/sft-$MODE
TABLE="$OUT/comparison-table.md"

echo "input: $PREV_MODEL, $NEW_MODEL"
echo "output: $OUT, $TABLE"

[ -d "$NEW_MODEL" ] || { echo "ERROR: $NEW_MODEL 없음 — 먼저 sft-06 + sft-07 을 --mode $MODE 로 실행하세요." >&2; exit 1; }

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

do_compare() {
  run_eval "$PREV_MODEL" "$GENERAL_TASKS" prev-general
  run_eval "$NEW_MODEL"  "$GENERAL_TASKS" new-general
  run_eval "$PREV_MODEL" "$KOREAN_TASKS"  prev-korean
  run_eval "$NEW_MODEL"  "$KOREAN_TASKS"  new-korean

  uv run python eval_compare_table.py "$OUT" \
    --labels "prev=$PREV_LABEL,new=$NEW_LABEL" | tee "$TABLE"
}

_make "$TABLE" "$PREV_MODEL" "$NEW_MODEL" -- do_compare

echo "input: $PREV_MODEL, $NEW_MODEL"
echo "output: $OUT, $TABLE"
