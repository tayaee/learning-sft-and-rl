# Learning SFT & RL with Axolotl

A hands-on study repo for running **SFT, DPO, GRPO, and ORPO** on Qwen2.5-1.5B-Instruct
with [Axolotl](https://github.com/axolotl-ai-cloud/axolotl), targeting Korean
chain-of-thought reasoning data. Each stage builds on the previous one:

```
Base (Qwen2.5-1.5B-Instruct)
   │
   ▼  SFT  ─────────────────────► [sft-demo.md]
   │
   ├─▼  DPO  (from SFT)  ──────► [rl-dpo-demo.md]
   │
   ├─▼  GRPO (from SFT)  ──────► [rl-grpo-demo.md]
   │
   └─▼  ORPO (from SFT)  ──────► [rl-orpo-demo.md]
```

## 1. SFT — Supervised Fine-Tuning
How to run a LoRA SFT on top of a base Instruct model with Axolotl, then merge
the adapter into a single deployable checkpoint.
→ See **[`sft-demo.md`](sft-demo.md)** — base sanity check, data sanity,
config review, train, LoRA merge, side-by-side inference, lm-eval.

## 2. DPO — Direct Preference Optimization
How to run a DPO pass on top of the SFT'd model using `(prompt, chosen, rejected)`
triples, then merge and compare.
→ See **[`rl-dpo-demo.md`](rl-dpo-demo.md)** — DPO data prep, Axolotl DPO config,
train, merge, 4-model comparison (Base vs SFT vs DPO), lm-eval.

## 3. GRPO — Group Relative Policy Optimization
How to run GRPO on top of the SFT'd model using only `(prompt)` + rule-based
reward functions (no preference labels), then merge and compare.
→ See **[`rl-grpo-demo.md`](rl-grpo-demo.md)** — reward function design,
Axolotl GRPO config, train, merge, 4-model comparison, lm-eval.

## 4. ORPO — Odds-Ratio Preference Optimization
How to run ORPO on top of the SFT'd model using the same `(prompt, chosen, rejected)`
pairs as DPO — but **without a reference model**. Provides two modes:
→ See **[`rl-orpo-demo.md`](rl-orpo-demo.md)**.
- **smoke test**: 20 pairs × `max_steps: 3` (~10분) — 파이프라인 점검용
- **full run**: 1000 pairs × 2 epochs (~1–2시간) — 휴리스틱 reward 기반 정량 평가 포함

## Stage diagrams

각 스테이지는 **smoke**(파이프라인 점검)와 **full**(실전 학습) 두 흐름으로 실행한다.
흐름마다 데이터·로그·출력 모델 디렉터리가 분리되어 있으므로 어느 순서로 실행해도
서로 덮어쓰지 않는다. 아래 다이어그램의 각 박스에는 프로세스별 in/out 을 표시했고,
바로 아래 코드 블록을 위에서부터 copy & paste 하면 그대로 따라간다.
(검토 전용 스크립트 — `*review*.sh`, `*sanity-check*.sh` — 는 산출물이 없어 생략)

> 공통 선행 조건: 모든 RL 스테이지(DPO/GRPO/ORPO)는 **같은 모드의 SFT merge 모델**이 필요하다.
> smoke 흐름은 `sft-*-smoke` 산출물을, full 흐름은 `sft-*-full` 산출물을 사용한다.

---

### SFT

#### smoke flow (~10분)

```
[in]  Qwen/Qwen2.5-1.5B-Instruct (base)
[in]  train.jsonl ──(앞 200건 자동 추출)──▶ data/smoke/train-sft.jsonl
   │
   ├─ sft-06-run-axolotl.sh smoke        Axolotl LoRA train
   │    in : configs/qwen2.5-1.5b-sft-smoke.yaml + data/smoke/train-sft.jsonl
   │    out: outputs/qwen2.5-1.5b-sft-smoke/              (LoRA adapter)
   │
   ├─ sft-07-merge.sh smoke               axolotl merge-lora
   │    in : outputs/qwen2.5-1.5b-sft-smoke/
   │    out: outputs/qwen2.5-1.5b-sft-smoke-merge/merged/ (HF model)
   │
   ├─ query_sft.py --mode smoke           추론 테스트
   │    in : .../qwen2.5-1.5b-sft-smoke-merge/merged/
   │
   └─ sft-11-lm-eval-sft.sh smoke         lm-eval (선택)
        in : .../qwen2.5-1.5b-sft-smoke-merge/merged/
        out: outputs/lm_eval_results/sft-smoke/
```

```bash
./sft-06-run-axolotl.sh smoke
./sft-07-merge.sh smoke
uv run query_sft.py --mode smoke "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
# (선택) ./sft-11-lm-eval-sft.sh smoke
```

#### full flow (~수 시간)

```
[in]  Qwen/Qwen2.5-1.5B-Instruct (base)
[in]  train.jsonl (50k Korean CoT, chat format)
   │
   ├─ sft-06-run-axolotl.sh full         Axolotl LoRA train
   │    in : configs/qwen2.5-1.5b-sft.yaml + train.jsonl
   │    out: outputs/qwen2.5-1.5b-sft/                    (LoRA adapter)
   │
   ├─ sft-07-merge.sh full                axolotl merge-lora
   │    in : outputs/qwen2.5-1.5b-sft/
   │    out: outputs/qwen2.5-1.5b-sft-merge/merged/       (HF model)
   │
   ├─ query_sft.py --mode full            추론 테스트
   │    in : .../qwen2.5-1.5b-sft-merge/merged/
   │
   ├─ sft-08-upload-to-hf.sh full         HF Hub 업로드 (선택)
   │    in : .../qwen2.5-1.5b-sft-merge/merged/
   │    out: tayaee/Qwen2.5-1.5B-Instruct-ko-Reasoning-alpha
   │
   └─ sft-11-lm-eval-sft.sh full          lm-eval (선택)
        in : .../qwen2.5-1.5b-sft-merge/merged/
        out: outputs/lm_eval_results/sft-full/
```

```bash
./sft-06-run-axolotl.sh full
./sft-07-merge.sh full
uv run query_sft.py --mode full "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
# (선택) ./sft-08-upload-to-hf.sh full
# (선택) ./sft-11-lm-eval-sft.sh full
```

---

### DPO (from SFT)

#### smoke flow (~30분, SFT-smoke merge 필요)

```
[in]  SFT-smoke merge 모델  outputs/qwen2.5-1.5b-sft-smoke-merge/merged/
[in]  train.jsonl (프롬프트 소스) + Qwen/Qwen2.5-1.5B-Instruct (rejected 후보)
   │
   ├─ rl-dpo-01-make-rl-dpo-data.sh smoke    rejection sampling 으로 선호 쌍 생성
   │    in : SFT-smoke merge 모델 + base 모델
   │    out: data/smoke/train_rl-dpo.jsonl  (50 pairs)
   │         data/smoke/sample_rl-dpo.jsonl (디버깅용 샘플)
   │
   ├─ rl-dpo-04-run-axolotl.sh smoke         Axolotl DPO train
   │    in : configs/qwen2.5-1.5b-rl-dpo-smoke.yaml + data/smoke/train_rl-dpo.jsonl
   │    out: outputs/qwen2.5-1.5b-rl-dpo-smoke/           (LoRA adapter)
   │
   ├─ rl-dpo-06-merge.sh smoke               axolotl merge-lora
   │    in : outputs/qwen2.5-1.5b-rl-dpo-smoke/
   │    out: outputs/qwen2.5-1.5b-rl-dpo-smoke-merge/merged/
   │
   ├─ rl-dpo-05-test-models.sh smoke         단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-dpo-smoke-merge/merged/
   │
   └─ rl-dpo-09-lm-eval-rl-dpo.sh smoke      lm-eval (선택)
        in : .../qwen2.5-1.5b-rl-dpo-smoke-merge/merged/
        out: outputs/lm_eval_results/rl-dpo-smoke/
```

```bash
./rl-dpo-01-make-rl-dpo-data.sh smoke
./rl-dpo-04-run-axolotl.sh smoke
./rl-dpo-06-merge.sh smoke
./rl-dpo-05-test-models.sh smoke "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
# (선택) ./rl-dpo-09-lm-eval-rl-dpo.sh smoke
```

#### full flow (~1–3시간, SFT-full merge 필요)

```
[in]  SFT-full merge 모델  outputs/qwen2.5-1.5b-sft-merge/merged/
[in]  train.jsonl (프롬프트 소스) + Qwen/Qwen2.5-1.5B-Instruct (rejected 후보)
   │
   ├─ rl-dpo-01-make-rl-dpo-data.sh full
   │    in : SFT-full merge 모델 + base 모델
   │    out: data/full/train_rl-dpo.jsonl  (1000 pairs)
   │         data/full/sample_rl-dpo.jsonl
   │
   ├─ rl-dpo-04-run-axolotl.sh full
   │    in : configs/qwen2.5-1.5b-rl-dpo.yaml + data/full/train_rl-dpo.jsonl
   │    out: outputs/qwen2.5-1.5b-rl-dpo/                 (LoRA adapter)
   │
   ├─ rl-dpo-06-merge.sh full
   │    in : outputs/qwen2.5-1.5b-rl-dpo/
   │    out: outputs/qwen2.5-1.5b-rl-dpo-merge/merged/
   │
   ├─ rl-dpo-05-test-models.sh full          단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-dpo-merge/merged/
   │
   └─ rl-dpo-09-lm-eval-rl-dpo.sh full       lm-eval (선택)
        in : .../qwen2.5-1.5b-rl-dpo-merge/merged/
        out: outputs/lm_eval_results/rl-dpo-full/
```

```bash
./rl-dpo-01-make-rl-dpo-data.sh full
./rl-dpo-04-run-axolotl.sh full
./rl-dpo-06-merge.sh full
./rl-dpo-05-test-models.sh full "피타고라스 정리를 증명하시오."
# (선택) ./rl-dpo-09-lm-eval-rl-dpo.sh full
```

---

### GRPO (from SFT)

> 사전 준비: `data/smoke/sample_rl-grpo.jsonl` (20 prompts),
> `data/full/sample_rl-grpo.jsonl` (확장 버전) — prompt-only JSONL 을 직접 준비한다.

#### smoke flow (~20분, SFT-smoke merge 필요)

```
[in]  SFT-smoke merge 모델  outputs/qwen2.5-1.5b-sft-smoke-merge/merged/
[in]  data/smoke/sample_rl-grpo.jsonl (prompt only) + reward_fn.py
   │
   ├─ rl-grpo-04-run-axolotl.sh smoke        Axolotl GRPO train
   │    in : configs/qwen2.5-1.5b-rl-grpo-smoke.yaml
   │          + data/smoke/sample_rl-grpo.jsonl + reward_fn.py
   │    out: outputs/qwen2.5-1.5b-rl-grpo-smoke/          (LoRA adapter)
   │
   ├─ rl-grpo-06-merge.sh smoke              axolotl merge-lora
   │    in : outputs/qwen2.5-1.5b-rl-grpo-smoke/
   │    out: outputs/qwen2.5-1.5b-rl-grpo-smoke-merge/merged/
   │
   ├─ rl-grpo-05-test-model.sh smoke         단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-grpo-smoke-merge/merged/
   │
   └─ rl-grpo-09-lm-eval-rl-grpo.sh smoke    lm-eval (선택)
        in : .../qwen2.5-1.5b-rl-grpo-smoke-merge/merged/
        out: outputs/lm_eval_results/rl-grpo-smoke/
```

```bash
./rl-grpo-04-run-axolotl.sh smoke
./rl-grpo-06-merge.sh smoke
./rl-grpo-05-test-model.sh smoke "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
# (선택) ./rl-grpo-09-lm-eval-rl-grpo.sh smoke
```

#### full flow (~1–2시간+, SFT-full merge 필요)

```
[in]  SFT-full merge 모델  outputs/qwen2.5-1.5b-sft-merge/merged/
[in]  data/full/sample_rl-grpo.jsonl (prompt only) + reward_fn.py
   │
   ├─ rl-grpo-04-run-axolotl.sh full
   │    in : configs/qwen2.5-1.5b-rl-grpo.yaml
   │          + data/full/sample_rl-grpo.jsonl + reward_fn.py
   │    out: outputs/qwen2.5-1.5b-rl-grpo/                (LoRA adapter)
   │
   ├─ rl-grpo-06-merge.sh full
   │    in : outputs/qwen2.5-1.5b-rl-grpo/
   │    out: outputs/qwen2.5-1.5b-rl-grpo-merge/merged/
   │
   ├─ rl-grpo-05-test-model.sh full          단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-grpo-merge/merged/
   │
   └─ rl-grpo-09-lm-eval-rl-grpo.sh full     lm-eval (선택)
        in : .../qwen2.5-1.5b-rl-grpo-merge/merged/
        out: outputs/lm_eval_results/rl-grpo-full/
```

```bash
./rl-grpo-04-run-axolotl.sh full
./rl-grpo-06-merge.sh full
./rl-grpo-05-test-model.sh full "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
# (선택) ./rl-grpo-09-lm-eval-rl-grpo.sh full
```

---

### ORPO (from SFT, reference model 불필요)

#### smoke flow (~15분, DPO-smoke 데이터 필요)

```
[in]  data/smoke/train_rl-dpo.jsonl (DPO-smoke 선호 쌍 재사용)
   │
   ├─ rl-orpo-01-make-orpo-data.sh smoke     DPO → ORPO 메시지 리스트 포맷 변환
   │    in : data/smoke/train_rl-dpo.jsonl
   │    out: data/smoke/train_rl-orpo.jsonl (20 pairs)
   │
   ├─ rl-orpo-04-run-axolotl.sh smoke        Axolotl ORPO train
   │    in : configs/qwen2.5-1.5b-rl-orpo-smoke.yaml + data/smoke/train_rl-orpo.jsonl
   │    out: outputs/qwen2.5-1.5b-rl-orpo-smoke/          (LoRA adapter)
   │
   ├─ rl-orpo-05-merge.sh smoke              axolotl merge-lora
   │    in : outputs/qwen2.5-1.5b-rl-orpo-smoke/
   │    out: outputs/qwen2.5-1.5b-rl-orpo-smoke-merge/merged/
   │
   ├─ rl-orpo-06-test-model.sh smoke         단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-orpo-smoke-merge/merged/
   │
   └─ rl-orpo-08-reward-eval.sh smoke        SFT vs ORPO reward 정량 비교 (선택)
        in : SFT-smoke merge + ORPO-smoke merge 모델
        out: outputs/eval_results/orpo-reward-smoke.jsonl
```

```bash
./rl-orpo-01-make-orpo-data.sh smoke
./rl-orpo-04-run-axolotl.sh smoke
./rl-orpo-05-merge.sh smoke
./rl-orpo-06-test-model.sh smoke
# (선택) ./rl-orpo-08-reward-eval.sh smoke
```

#### full flow (~1–2시간, DPO-full 데이터 필요)

```
[in]  data/full/train_rl-dpo.jsonl (DPO-full 선호 쌍 재사용)
   │
   ├─ rl-orpo-01-make-orpo-data.sh full
   │    in : data/full/train_rl-dpo.jsonl
   │    out: data/full/train_rl-orpo.jsonl (1000 pairs)
   │
   ├─ rl-orpo-04-run-axolotl.sh full
   │    in : configs/qwen2.5-1.5b-rl-orpo.yaml + data/full/train_rl-orpo.jsonl
   │    out: outputs/qwen2.5-1.5b-rl-orpo/                (LoRA adapter)
   │
   ├─ rl-orpo-05-merge.sh full
   │    in : outputs/qwen2.5-1.5b-rl-orpo/
   │    out: outputs/qwen2.5-1.5b-rl-orpo-merge/merged/
   │
   ├─ rl-orpo-06-test-model.sh full          단일 추론 테스트
   │    in : .../qwen2.5-1.5b-rl-orpo-merge/merged/
   │
   ├─ rl-orpo-08-reward-eval.sh full         SFT vs ORPO reward 정량 비교
   │    in : SFT-full merge + ORPO-full merge 모델
   │    out: outputs/eval_results/orpo-reward-full.jsonl
   │
   └─ rl-orpo-09-lm-eval-rl-orpo.sh full     lm-eval (선택)
        in : .../qwen2.5-1.5b-rl-orpo-merge/merged/
        out: outputs/lm_eval_results/rl-orpo-full/
```

```bash
./rl-orpo-01-make-orpo-data.sh full
./rl-orpo-04-run-axolotl.sh full
./rl-orpo-05-merge.sh full
./rl-orpo-06-test-model.sh full
./rl-orpo-08-reward-eval.sh full
# (선택) ./rl-orpo-09-lm-eval-rl-orpo.sh full
```


## Repository layout

```
configs/                       Axolotl YAML configs (sft / rl-dpo / rl-grpo / rl-orpo / lm_eval)
data/                          Training & sample JSONLs
sft-*.sh / rl-dpo-*.sh / rl-grpo-*.sh    Per-stage driver scripts
query-*.py                     Inference scripts (base / sft / rl-dpo / rl-grpo)
reward_fn.py                   Rule-based rewards for GRPO
sft-12 / rl-{dpo,grpo,orpo}-10-eval-compare.sh    이전/새 모델 2개 평가(tinyBenchmarks + KO-BEST) 비교표
eval_compare_table.py          eval-compare 결과 → markdown 비교표 생성
make_rl_dpo_data.py            Script to build DPO preference pairs
make_rl_orpo_data.py           Script to build ORPO data (reuses DPO pairs)
eval_orpo_reward.py            Heuristic-reward eval: SFT vs ORPO
sft-demo.md / rl-dpo-demo.md / rl-grpo-demo.md / rl-orpo-demo.md    Step-by-step study notes
```

## Quick start

모든 학습/데이터 스크립트는 첫 인자로 `smoke | full` 을 반드시 받으며,
데이터(`data/smoke/`, `data/full/`)·로그·출력 모델이 모드별로 분리되어 있어
어떤 순서로 실행해도 서로 덮어쓰지 않는다.

모드 지정 스크립트에는 `<script>-smoke.sh` / `<script>-full.sh` 래퍼도 있다
(예: `./sft-06-run-axolotl-full.sh` ≡ `./sft-06-run-axolotl.sh full`).

```bash
# 1) SFT
./sft-06-run-axolotl.sh full
./sft-07-merge.sh full
uv run query_sft.py --mode full "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."

# 2) DPO (requires SFT merge output of the same mode)
./rl-dpo-01-make-rl-dpo-data.sh full      # → data/full/train_rl-dpo.jsonl
./rl-dpo-04-run-axolotl.sh full
./rl-dpo-06-merge.sh full
uv run query_rl_dpo.py --mode full "피타고라스 정리를 증명하시오."

# 3) GRPO (requires SFT merge output)
./rl-grpo-04-run-axolotl.sh full          # data/full/sample_rl-grpo.jsonl 사용
./rl-grpo-06-merge.sh full
uv run query_rl_grpo.py --mode full "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."

# 4) ORPO — smoke 으로 점검 후 full 실행 (requires DPO data of the same mode)
./rl-dpo-01-make-rl-dpo-data.sh smoke     # → data/smoke/train_rl-dpo.jsonl
./rl-orpo-01-make-orpo-data.sh smoke      # → data/smoke/train_rl-orpo.jsonl
./rl-orpo-04-run-axolotl.sh smoke && \
  ./rl-orpo-05-merge.sh smoke && ./rl-orpo-06-test-model.sh smoke
./rl-orpo-01-make-orpo-data.sh full       # → data/full/train_rl-orpo.jsonl
./rl-orpo-04-run-axolotl.sh full && ./rl-orpo-05-merge.sh full && \
  ./rl-orpo-08-reward-eval.sh full

# 5) 4-model side-by-side (같은 모드의 merge 모델끼리 비교)
./rl-grpo-08-pythagorean-theorem.sh full
```

Each `*-demo.md` contains the full walkthrough with troubleshooting, expected
checkpoints, and parameter rationale. Read the demo file for the stage you are
on before running its scripts.

### 모델 비교 평가 (eval-compare)

새 모델을 만든 뒤 **이전 모델 vs 새 모델** 에 대해 2개의 빠른 평가를 돌리고
비교표를 생성한다. 전부 loglikelihood 방식이라 수 분 내 완료된다.

- 평가 ① General 지능: `tinyArc`, `tinyHellaswag`, `tinyMMLU`, `tinyWinogrande` (TinyBenchmarks 100문제씩)
- 평가 ② Korean: `kobest_copa`, `kobest_hellaswag`
- 비교 대상: SFT=Base, DPO/GRPO/ORPO=같은 모드의 SFT merge 모델

```bash
./sft-12-eval-compare.sh smoke        # Base vs SFT-smoke
./rl-dpo-10-eval-compare.sh full      # SFT(full) vs DPO(full)
# → outputs/lm_eval_results/<stage>-<mode>/comparison-table.md 에 표 저장
```
> 참고: 선호 정렬(DPO/ORPO)은 벤치마크 점수를 낮출 수 있다(스타일 변화).
> 같은 조건(`--apply_chat_template`)으로 이전/새 모델을 함께 돌리므로 Δ 값을 보자.

## Requirements

- NVIDIA GPU (Blackwell / sm_120 tested with `uv` + `UV_TORCH_BACKEND=cu130`)
- `uv` package manager
- Python 3.12, CUDA 13.0 toolchain
- ~50 GB disk for base model + training outputs