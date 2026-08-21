# RL Demo — DPO on top of SFT'd Qwen2.5-1.5B

> **목적**: SFT'd 모델(`outputs/qwen2.5-1.5b-sft-merge/merged`)을 시작점으로,
> **합성 선호 데이터** 로 **DPO** 를 추가 학습해 응답 일관성·구조를 더 강화.
> 사전 조건: [`sft-demo.md`](sft-demo.md) Stage 4 완료 (SFT merge 폴더 존재).

---

## 0. RL 알고리즘 선택 — DPO

| 알고리즘 | 데이터 | 복잡도 | 비고 |
|----------|--------|--------|------|
| **DPO** | (prompt, chosen, rejected) | 낮음 | reference model 1개, 가장 진입 쉬움 |
| ORPO | (prompt, chosen, rejected) | 낮음 | reference model 없음 |
| GRPO | (prompt) + 보상함수 | 중간 | N개 sample, KL 없이 group-relative |
| PPO | (prompt) + reward model | 높음 | 별도 reward model 필요 |

여기선 **DPO** 를 사용합니다. 이유:
- SFT'd 모델을 시작점으로 사용 가능
- reference model 은 베이스 모델 (`Qwen/Qwen2.5-1.5B-Instruct`) 자동 지정
- 합성 선호 데이터를 스크립트(`make_rl-dpo_data.py`)로 만들 수 있음

---

## 1. 선호 데이터 생성 (10–30분)

```bash
cd /home/user1/git/learning-sft-and-rl
mkdir -p data

# 베이스 + SFT'd 모델 로드 → 1000 prompts × 4 samples K=4 → 1000 pairs
uv run python make_rl-dpo_data.py \
  --sft-model ./outputs/qwen2.5-1.5b-sft-merge/merged \
  --base-model Qwen/Qwen2.5-1.5B-Instruct \
  --num-prompts 1000 \
  --samples-per-prompt 4 \
  --out data/train_rl-dpo.jsonl \
  --sample-out data/sample_rl-dpo.jsonl
```

**생성 원리**:
1. `train.jsonl`에서 N=1000 prompt 샘플링
2. 각 prompt마다 SFT'd 모델에서 K=4개 응답 (T=0.7 sampling)
3. 각 응답에 점수 부여 (  블록,  ###  구조, 적정 길이, 결론 단정)
4. 점수 최고 = chosen, 점수 최저 = rejected
5. 베이스 모델 출력 (T=0.0) 도 rejected 후보로 추가

**출력**:
- `data/train_rl-dpo.jsonl` — DPO 학습용 (1000 pairs)
- `data/sample_rl-dpo.jsonl` — 디버깅용 (50 pairs)

확인:
```bash
wc -l data/train_rl-dpo.jsonl data/sample_rl-dpo.jsonl
head -1 data/sample_rl-dpo.jsonl | uv run python -m json.tool | head -10
```

---

## 2. 합성 데이터 품질 체크 (1분)

```bash
# 같은 prompt 에 대한 chosen vs rejected 비교
head -1 data/sample_rl-dpo.jsonl | uv run python -c "
import json, sys
d = json.loads(sys.stdin.read())
print('=== PROMPT ===')
print(d['prompt'][:200])
print('\n=== CHOSEN ===')
print(d['chosen'][:400])
print('\n=== REJECTED ===')
print(d['rejected'][:400])
"
```

**기대**: `chosen`은  블록 +  ###  구조, `rejected`는 짧고 평평한 응답.

---

## 3. DPO config 검증 (1분)

```bash
cat configs/qwen2.5-1.5b-rl-dpo.yaml | head -20
```

핵심 파라미터:
- `base_model: ./outputs/qwen2.5-1.5b-sft-merge/merged` (SFT'd 모델에서 시작)
- `rl: dpo`, `dpo_beta: 0.1`, `dpo_loss_type: sigmoid`
- `ref_model: Qwen/Qwen2.5-1.5B-Instruct` (베이스 모델이 reference)
- `learning_rate: 5e-6` (DPO는 SFT보다 10–20× 낮은 LR)
- `micro_batch_size: 2, gradient_accumulation_steps: 8` → effective batch 16

---

## 4. DPO 학습 (30–60분)

```bash
cd /home/user1/git/learning-sft-and-rl

# 모니터링 (별도 터미널)
watch -n 5 nvidia-smi

# 학습 시작
uv run axolotl train configs/qwen2.5-1.5b-rl-dpo.yaml 2>&1 | tee logs/rl-dpo.log
```

**체크 포인트**:
- DPO loss  시작 ~0.69 → 점진적 감소
- `reward_margin` (chosen - rejected 보상 차이)  양수로 증가 ⇒ 정상
- DPO 는 SFT보다 훨씬 빠름 (1k pairs × 1 epoch)
- 완료 시 `./outputs/qwen2.5-1.5b-rl-dpo/` 에 **LoRA 어댑터만** 저장됨
- merge된 모델은 Stage 5에서 별도 생성 (`./outputs/qwen2.5-1.5b-rl-dpo-merge/merged/`)

---

## 5. LoRA merge (1분)

> axolotl `train`은 LoRA 어댑터만 저장하므로 **merge 단계가 별도로 필요**합니다.
> merge된 base+LoRA 모델이 있어야 `query-rl-dpo.py`로 추론할 수 있습니다.

```bash
cd /home/user1/git/learning-sft-and-rl
./rl-dpo-06-merge.sh
```

- axolotl은 항상 `output_dir` 하위에 `merged/` 폴더를 만들어 저장
  → 최종 경로: `./outputs/qwen2.5-1.5b-rl-dpo-merge/merged/`

확인:
```bash
ls outputs/qwen2.5-1.5b-rl-dpo-merge/merged/   # config.json, model.safetensors, tokenizer.* 등
```

---

## 6. RL 모델 검증 (1분)

```bash
# merge 폴더 확인
ls outputs/qwen2.5-1.5b-rl-dpo-merge/merged/

# 추론
uv run query-rl-dpo.py "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
```

**기대 출력**: SFT'd 보다 더 일관된  ###  구조 응답.

---

## 7. 세 모델 비교 (5분)

| 모델 | 스크립트 | 경로 |
|------|----------|------|
| BASE | `query-base.py` | `Qwen/Qwen2.5-1.5B-Instruct` |
| SFTED | `query-sft.py` | `./outputs/qwen2.5-1.5b-sft-merge/merged` |
| RL | `query-rl-dpo.py` | `./outputs/qwen2.5-1.5b-rl-dpo-merge/merged` |

```bash
# 3-way 동일 질문 비교
Q="피타고라스 정리를 증명하시오."
uv run query-base.py  "$Q"
uv run query-sft.py "$Q"
uv run query-rl-dpo.py    "$Q"
```

REPL 모드:
```bash
uv run query-base.py    # 동일 질문을 3 모델에 반복
uv run query-sft.py
uv run query-rl-dpo.py
```

---

## 8. lm-eval 정량 평가 (선택, 3분)

정성 비교와 별개로 DPO 모델의 표준 benchmark 점수를 측정.
각 task 당 100 samples 제한 (`--limit 100`) 으로 sanity check 용도.

```bash
./rl-dpo-09-lm-eval-rl-dpo.sh
```

평가 tasks:
- 한국어: `kobest_hellaswag`, `kobest_copa`, `kmmlu`
- 영어: `hellaswag`, `arc_easy`, `piqa`, `winogrande`

결과는 `outputs/lm_eval_results/rl-dpo/` 에 저장됨.
비교용 BASE/SFT 점수는 [`sft-demo.md`](sft-demo.md) Stage 8 의 `sft-10`, `sft-11` 결과와 함께 봐야 함.

> 참고: chat template 적용 모델의 경우 `kmmlu` 가 raw 점수보다 낮게
> 나오는 경향이 있음 (선지 형식 차이). 정성 비교와 함께 봐야 함.

---

## 9. 차이 요약

| 모델 |  블록 |  단계 구조 | 한국어 일관성 | 응답 일관성 |
|------|-------|-----------|-------------|-----------|
| BASE | 약함 | 약함 | 보통 | 보통 |
| SFTED | 강함 | 강함 | 자연스러움 | 보통 |
| RL    | 강함 | 강함 | 자연스러움 | **더 일관** |

DPO 의 효과:
- SFT'd 모델이 가끔 짧게 끊기거나  ###  헤더 빠뜨린 응답 → DPO 가 페널티
- 베이스식 평평한 응답 → DPO 가 페널티
- 구조적이고 일관된 응답 → DPO 가 보상

---

## 10. 한 줄 요약

```bash
# SFT 가 끝났다면
uv run python make_rl-dpo_data.py && \
  uv run axolotl train configs/qwen2.5-1.5b-rl-dpo.yaml && \
  ./rl-dpo-06-merge.sh && \
  uv run query-rl-dpo.py
```

---

## 트러블슈팅

| 증상 | 해결 |
|------|------|
| `ref_model` 로딩 실패 | `HF_HUB_OFFLINE=1` 유지 + 로컬 캐시 확인 |
| DPO loss 가 0.69 그대로 | learning_rate 너무 낮음 → `1e-5` 로 |
| `reward_margin` 음수 | 데이터 품질 문제 → `make_rl-dpo_data.py` 의 `--num-prompts` 늘리기 |
| `outputs/qwen2.5-1.5b-rl-dpo-merge` 없음 | train 로그 확인. **Stage 5 `axolotl merge-lora` 명령 실행 필수** (train은 LoRA 어댑터만 저장, merge 별도 단계). 또한 `lora_model_dir` 는 merge 출력 경로가 아니라 어댑터 **입력** 경로임 |
| 두 모델 출력이 똑같음 | DPO lr/epoch 부족 |

---

## 부록: GRPO (rule-based reward) 으로 업그레이드

수학 정답이 명확한 문제라면 rule-based 보상 함수로 GRPO 가능:

```python
# reward_fn.py
def math_reward(prompt, response, ground_truth):
    import re
    m = re.search(r"\\boxed\{([^}]+)\}", response)
    if not m: return 0.0
    pred = m.group(1).strip()
    return 1.0 if pred == ground_truth else 0.0
```

```yaml
# configs/qwen2.5-1.5b-rl-grpo.yaml (대략)
rl: grpo
reward_fn: path/to/reward_fn.py
```

> 본 데모 데이터(`amphora/korean-reasoning-small`)는 정답을 로 추출하기 어려운
> 일반 추론 데이터라 DPO 가 더 적합합니다. 수학 전용 데이터셋이라면 GRPO 추천.
