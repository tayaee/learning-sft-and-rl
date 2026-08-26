#!/usr/bin/env bash
# sft-01-install-dependencies.sh
# 모든 의존성(torch, axolotl[deepspeed,flash-attn], datasets, torchao, packaging 등)은
# pyproject.toml 에 이미 선언되어 있으므로 `uv sync` 만 실행하면 된다.
# - torch 백엔드: 환경변수 UV_TORCH_BACKEND=cu130 (Blackwell / sm_120, README 참조)
# - axolotl 의 deepspeed/flash-attn extras 는 pyproject.toml dependencies 에 포함되어
#   `--no-build-isolation` 으로 한 번에 설치됨 (deprecation 으로 향후 deprecated 예정)
# - AWS CLI 는 s3 동기화가 필요한 경우 `uv add awscli` 로 별도 추가 가능 (기본은 제외)
set -euo pipefail

echo "input: pyproject.toml, uv.lock"
echo "output: .venv"

set -x
UV_TORCH_BACKEND="${UV_TORCH_BACKEND:-cu130}" uv sync
set +x

echo "input: pyproject.toml, uv.lock"
echo "output: .venv"
