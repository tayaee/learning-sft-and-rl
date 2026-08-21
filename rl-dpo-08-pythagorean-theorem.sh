#!/bin/bash -x
Q="피타고라스 정리를 증명하시오."
uv run query-base.py "$Q"
uv run query-sft.py "$Q"
uv run query-rl-dpo.py "$Q"
