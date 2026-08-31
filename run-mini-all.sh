#!/bin/bash
# mini pipeline driver — runs each stage's mini scripts and captures file changes.
set -u
cd /home/user1/git/learning-sft-and-rl

OUT=files-changed.txt
: > "$OUT"
echo "$(date) — Mini pipeline test (sft → dpo → orpo → grpo)" >> "$OUT"
echo "" >> "$OUT"
echo "Capture: find . -newer /tmp/mark -type f -ls 2>/dev/null" >> "$OUT"
echo "Symlinks shown separately with find ... -type l -ls 2>/dev/null" >> "$OUT"
echo "" >> "$OUT"

stage_header() {
  local stage="$1" mode="$2"
  echo "" >> "$OUT"
  echo "================================================================================" >> "$OUT"
  echo "STAGE: ${stage} (${mode})" >> "$OUT"
  echo "================================================================================" >> "$OUT"
}

stage_in_config() {
  local stage="$1" mode="$2"
  echo "" >> "$OUT"
  echo "### Stage start: ${stage} ${mode} — in/ and config/ ###" >> "$OUT"
  for kind in in config; do
    echo "" >> "$OUT"
    echo "## data/${stage}-${mode}-${kind}/" >> "$OUT"
    find "data/${stage}-${mode}-${kind}" \( -type f -o -type l \) -ls 2>/dev/null >> "$OUT"
    echo "(end)" >> "$OUT"
  done
}

stage_out() {
  local stage="$1" mode="$2"
  echo "" >> "$OUT"
  echo "### Stage end: ${stage} ${mode} — out/ ###" >> "$OUT"
  echo "## data/${stage}-${mode}-out/" >> "$OUT"
  find "data/${stage}-${mode}-out" \( -type f -o -type l \) -ls 2>/dev/null >> "$OUT"
  echo "(end)" >> "$OUT"
}

run_one() {
  local script="$1"
  echo "" >> "$OUT"
  echo "--- Script: ${script} ---" >> "$OUT"
  touch /tmp/mark
  bash "$script" >> "$OUT" 2>&1
  local rc=$?
  echo "" >> "$OUT"
  echo "Exit code: ${rc}" >> "$OUT"
  echo "Files newer than /tmp/mark:" >> "$OUT"
  find . -newer /tmp/mark \( -type f -o -type l \) -ls 2>/dev/null >> "$OUT"
  echo "(end of changes for ${script})" >> "$OUT"
  return $rc
}

# === STAGE 1: SFT ===
stage_header sft mini
stage_in_config sft mini
for s in sft-mini-05-review-sft-config-mini.sh sft-mini-06-run-axolotl-mini.sh sft-mini-07-merge-mini.sh sft-mini-11-lm-eval-sft-mini.sh sft-mini-12-eval-compare-mini.sh; do
  run_one "$s" || { echo "FAILED: $s" >> "$OUT"; break; }
done
stage_out sft mini

# === STAGE 2: DPO ===
stage_header dpo mini
stage_in_config dpo mini
for s in rl-dpo-mini-01-make-rl-dpo-data.sh rl-dpo-mini-02-sanity-check-rl-dpo-data-mini.sh rl-dpo-mini-03-review-rl-dpo-config-mini.sh rl-dpo-mini-04-run-axolotl-mini.sh rl-dpo-mini-05-test-models-mini.sh rl-dpo-mini-06-merge-mini.sh rl-dpo-mini-09-lm-eval-rl-dpo-mini.sh rl-dpo-mini-10-eval-compare-mini.sh; do
  run_one "$s" || { echo "FAILED: $s" >> "$OUT"; break; }
done
stage_out dpo mini

# === STAGE 3: ORPO ===
stage_header orpo mini
stage_in_config orpo mini
for s in rl-orpo-mini-01-make-orpo-data-mini.sh rl-orpo-mini-02-sanity-check-orpo-data-mini.sh rl-orpo-mini-03-review-orpo-config-mini.sh rl-orpo-mini-04-run-axolotl-mini.sh rl-orpo-mini-05-merge-mini.sh rl-orpo-mini-06-test-model-mini.sh rl-orpo-mini-08-reward-eval-mini.sh rl-orpo-mini-09-lm-eval-rl-orpo-mini.sh rl-orpo-mini-10-eval-compare-mini.sh; do
  run_one "$s" || { echo "FAILED: $s" >> "$OUT"; break; }
done
stage_out orpo mini

# === STAGE 4: GRPO ===
stage_header grpo mini
stage_in_config grpo mini
for s in rl-grpo-mini-01-review-data-mini.sh rl-grpo-mini-02-review-reward-fn.sh rl-grpo-mini-03-review-rl-grpo-config-mini.sh rl-grpo-mini-04-run-axolotl-mini.sh rl-grpo-mini-05-test-model-mini.sh rl-grpo-mini-06-merge-mini.sh rl-grpo-mini-09-lm-eval-rl-grpo-mini.sh rl-grpo-mini-10-eval-compare-mini.sh; do
  run_one "$s" || { echo "FAILED: $s" >> "$OUT"; break; }
done
stage_out grpo mini

echo "" >> "$OUT"
echo "================================================================================" >> "$OUT"
echo "PIPELINE COMPLETE — $(date)" >> "$OUT"
echo "================================================================================" >> "$OUT"