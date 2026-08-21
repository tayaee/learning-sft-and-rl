# Learning SFT & RL with Axolotl

A hands-on study repo for running **SFT, DPO, and GRPO** on Qwen2.5-1.5B-Instruct
with [Axolotl](https://github.com/axolotl-ai-cloud/axolotl), targeting Korean
chain-of-thought reasoning data. Each stage builds on the previous one:

```
Base (Qwen2.5-1.5B-Instruct)
   │
   ▼  SFT  ─────────────────────► [sft-demo.md]
   │
   ├─▼  DPO  (from SFT)  ──────► [rl-dpo-demo.md]
   │
   └─▼  GRPO (from SFT)  ──────► [rl-grpo-demo.md]
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

## Stage diagrams

Each stage takes a **model** + **data** as input, runs them through Axolotl
(train → merge), produces a Hugging Face model, and is served via vLLM.

### SFT
```
Qwen/Qwen2.5-1.5B-Instruct   train.jsonl   (50k Korean CoT, chat format)
        │                          │
        └──────────┬───────────────┘
                   ▼
            ┌─────────────┐
            │   Axolotl   │
            │ LoRA train  │  ← configs/qwen2.5-1.5b-sft.yaml
            └──────┬──────┘
                   ▼
            ./outputs/qwen2.5-1.5b-sft/        (LoRA adapter only)
                   │
                   ▼  axolotl merge-lora
            ./outputs/qwen2.5-1.5b-sft-merge/merged/   (HF model)
                   │
                   ▼  vllm serve
              consumer / query-sft.py
```

### DPO (from SFT)
```
SFT-merged model            data/train_rl-dpo.jsonl   (prompt, chosen, rejected)
        │                              │
        └──────────────┬───────────────┘
                       ▼
                ┌─────────────┐
                │   Axolotl   │
                │   DPO train │  ← configs/qwen2.5-1.5b-rl-dpo.yaml
                └──────┬──────┘
                       ▼
            ./outputs/qwen2.5-1.5b-rl-dpo/        (LoRA adapter only)
                       │
                       ▼  axolotl merge-lora
            ./outputs/qwen2.5-1.5b-rl-dpo-merge/merged/   (HF model)
                       │
                       ▼  vllm serve
                consumer / query-rl-dpo.py
```

### GRPO (from SFT)
```
SFT-merged model        data/sample_rl-grpo.jsonl   (prompt only)   reward_fn.py
        │                          │                          │
        └────────────┬─────────────┴────────────┬─────────────┘
                     ▼                          ▼
                ┌─────────────┐         (rule-based rewards)
                │   Axolotl   │
                │  GRPO train │  ← configs/qwen2.5-1.5b-rl-grpo.yaml
                └──────┬──────┘
                       ▼
            ./outputs/qwen2.5-1.5b-rl-grpo/        (LoRA adapter only)
                       │
                       ▼  axolotl merge-lora
            ./outputs/qwen2.5-1.5b-rl-grpo-merge/merged/   (HF model)
                       │
                       ▼  vllm serve
                consumer / query-rl-grpo.py
```

## Repository layout

```
configs/                       Axolotl YAML configs (sft / rl-dpo / rl-grpo / lm_eval)
data/                          Training & sample JSONLs
sft-*.sh / rl-dpo-*.sh / rl-grpo-*.sh    Per-stage driver scripts
query-*.py                     Inference scripts (base / sft / rl-dpo / rl-grpo)
reward_fn.py                   Rule-based rewards for GRPO
make_rl-dpo_data.py            Script to build DPO preference pairs
sft-demo.md / rl-dpo-demo.md / rl-grpo-demo.md    Step-by-step study notes
```

## Quick start

```bash
# 1) SFT
./sft-06-run-axolotl.sh
./sft-07-merge.sh
uv run query-sft.py "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."

# 2) DPO (requires SFT merge output)
./rl-dpo-04-run-axolotl.sh
./rl-dpo-06-merge.sh
uv run query-rl-dpo.py "피타고라스 정리를 증명하시오."

# 3) GRPO (requires SFT merge output)
./rl-grpo-04-run-axolotl.sh
./rl-grpo-06-merge.sh
uv run query-rl-grpo.py "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."

# 4) 4-model side-by-side
./rl-grpo-08-pythagorean-theorem.sh
```

Each `*-demo.md` contains the full walkthrough with troubleshooting, expected
checkpoints, and parameter rationale. Read the demo file for the stage you are
on before running its scripts.

## Requirements

- NVIDIA GPU (Blackwell / sm_120 tested with `uv` + `UV_TORCH_BACKEND=cu130`)
- `uv` package manager
- Python 3.12, CUDA 13.0 toolchain
- ~50 GB disk for base model + training outputs