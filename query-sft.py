#!/usr/bin/env python3
"""query-sft.py — SFT 완료된 LoRA-merge 모델 추론.

사용법:
    uv run query-sft.py "방정식 x^2 + 5x + 6 = 0 의 해를 구하시오."
    uv run query-sft.py                   # REPL 모드

모델 경로: ./outputs/qwen2.5-1.5b-sft-merge (SFT 학습 후 merge된 모델)
사전 요구: sft-demo.md 의 Stage 4 (axolotl train) 완료
"""
from __future__ import annotations

import argparse
import os
import sys

os.environ.setdefault("HF_HUB_OFFLINE", "0")
os.environ.setdefault("TRANSFORMERS_OFFLINE", "0")

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

SFT_MODEL = "./outputs/qwen2.5-1.5b-sft-merge/merged"


def build_argparser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="SFT merge 모델 추론")
    p.add_argument("prompt", nargs="*", help="한글 질문 (없으면 REPL)")
    p.add_argument("--max-new-tokens", type=int, default=512)
    p.add_argument("--temperature", type=float, default=0.0)
    p.add_argument("--dtype", default="bfloat16",
                   choices=["bfloat16", "float16", "float32"])
    return p


def load_model():
    if not os.path.isdir(SFT_MODEL):
        sys.exit(f"[sft] ERROR: {SFT_MODEL} 가 없습니다.\n"
                 f"  먼저 sft-demo.md Stage 4 (axolotl train) 을 완료하세요.")
    print(f"[sft] loading {SFT_MODEL} ...", flush=True)
    dtype = {"bfloat16": torch.bfloat16, "float16": torch.float16,
             "float32": torch.float32}[args.dtype]
    tok = AutoTokenizer.from_pretrained(SFT_MODEL)
    model = AutoModelForCausalLM.from_pretrained(
        SFT_MODEL,
        dtype=dtype,
        device_map="cuda:0",
        attn_implementation="sdpa",
    )
    model.eval()
    return tok, model


def ask(tok, model, prompt: str) -> str:
    msgs = [{"role": "user", "content": prompt}]
    text = tok.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True)
    ids = tok(text, return_tensors="pt").to(model.device)
    gen_kwargs = dict(
        max_new_tokens=args.max_new_tokens,
        do_sample=(args.temperature > 0.0),
        eos_token_id=tok.eos_token_id,
        pad_token_id=tok.eos_token_id,
    )
    if args.temperature > 0.0:
        gen_kwargs["temperature"] = args.temperature
        gen_kwargs["top_p"] = 0.95
    with torch.no_grad():
        out = model.generate(**ids, **gen_kwargs)
    gen = out[0, ids.input_ids.shape[1]:]
    return tok.decode(gen, skip_special_tokens=True)


def repl_mode(tok, model):
    print("\n=== REPL 모드 ('quit' / 'exit' / Ctrl-D 종료) ===\n")
    while True:
        try:
            q = input("[you] ").strip()
        except EOFError:
            print()
            break
        if not q or q.lower() in ("quit", "exit"):
            break
        print("\n=== SFT ===")
        print(ask(tok, model, q))
        print()


def main():
    global args
    args = build_argparser().parse_args()
    tok, model = load_model()

    if args.prompt:
        print("\n=== SFT ===")
        print(ask(tok, model, " ".join(args.prompt)))
    else:
        repl_mode(tok, model)


if __name__ == "__main__":
    main()
