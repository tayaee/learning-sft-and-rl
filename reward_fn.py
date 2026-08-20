"""reward_fn.py — GRPO 학습용 보상 함수 모음.

axolotl 의 GRPO 학습에서 trl.reward_funcs 로 참조.
시그니처:  def fn_name(completions, **kwargs) -> List[float]

completions:  [{"role": "assistant", "content": "..."}, ...]  형식의 dict 리스트
**kwargs:    데이터셋 컬럼 (예:  answer,  prompt 등).  본 데모에선 사용 안 함.
반환:   completions 와 같은 길이의 float 리스트 (None 가능 — 해당 샘플 제외)
"""
from __future__ import annotations

import re
from typing import List


# ---------------------------------------------------------
# 1. format_reward   ブロック  존재
# ---------------------------------------------------------
def format_reward(completions, **kwargs) -> List[float]:
    rewards = []
    for c in completions:
        text = c["content"] if isinstance(c, dict) else c[0]["content"]
        has_think = bool(re.search(r"<\s*think\s*>.*?<\s*/\s*think\s*>", text, re.DOTALL))
        rewards.append(0.5 if has_think else 0.0)
    return rewards


# ---------------------------------------------------------
# 2. structure_reward   ###  헤더로 결론 단정
# ---------------------------------------------------------
def structure_reward(completions, **kwargs) -> List[float]:
    rewards = []
    for c in completions:
        text = c["content"] if isinstance(c, dict) else c[0]["content"]
        n_headers = len(re.findall(r"^#+\s+", text, re.MULTILINE))
        has_conclusion = any(
            kw in text for kw in ["따라서", "결론적으로", "정리하면", "답은", "결과적으로"]
        )
        score = 0.0
        if n_headers >= 1:
            score += 0.3
        if n_headers >= 3:
            score += 0.2
        if has_conclusion:
            score += 0.3
        rewards.append(min(score, 1.0))
    return rewards


# ---------------------------------------------------------
# 3. length_reward   적절한 길이 (300–1500자)
# ---------------------------------------------------------
def length_reward(completions, **kwargs) -> List[float]:
    rewards = []
    for c in completions:
        text = c["content"] if isinstance(c, dict) else c[0]["content"]
        L = len(text)
        if L < 100:
            r = -0.5
        elif L < 300:
            r = 0.0
        elif L <= 1500:
            r = 1.0
        elif L <= 2500:
            r = 0.5
        else:
            r = -0.3  # 너무 길면 페널티 (repetition 위험)
        rewards.append(r)
    return rewards


# ---------------------------------------------------------
# 4. keyword_reward   한국어 학술 용어 등장
# ---------------------------------------------------------
KOREAN_ACADEMIC_TERMS = [
    # 수학
    "도함수", "극값", "미분", "적분", "방정식", "부등식", "함수", "정리", "공식",
    "증명", "귀류법", "수학적", "귀납법", "유리수", "무리수", "소수", "합성",
    # 과학
    "분배함수", "해밀토니안", "스핀", "양자", "광자", "전자", "원자", "분자",
    "중력", "에너지", "열역학", "현상", "측정", "관측",
    # 일반
    "조건", "구조", "관계", "패턴", "변환", "계산", "정의", "개념", "원리",
    "분석", "해석", "응용", "접근", "방법", "결과", "관점", "측면",
]


def keyword_reward(completions, **kwargs) -> List[float]:
    rewards = []
    for c in completions:
        text = c["content"] if isinstance(c, dict) else c[0]["content"]
        hits = sum(1 for kw in KOREAN_ACADEMIC_TERMS if kw in text)
        # 4개 이상이면 1.0, 0개면 0.0
        rewards.append(min(hits / 4.0, 1.0))
    return rewards


# ---------------------------------------------------------
# (참고) accuracy_reward   수학 정답 검증 — 정답 컬럼이 있을 때만 사용
# ---------------------------------------------------------
def accuracy_reward(completions, answer=None, **kwargs) -> List[float]:
    """answer 컬럼이 있을 때 \\\\boxed{...} 패턴과 비교."""
    if answer is None:
        return [0.0] * len(completions)
    rewards = []
    for c, a in zip(completions, answer):
        text = c["content"] if isinstance(c, dict) else c[0]["content"]
        m = re.search(r"\\boxed\{([^}]+)\}", text)
        if not m:
            rewards.append(0.0)
            continue
        pred = m.group(1).strip().replace(",", "").replace(" ", "")
        gold = str(a).strip().replace(",", "").replace(" ", "")
        rewards.append(1.0 if pred == gold else 0.0)
    return rewards
