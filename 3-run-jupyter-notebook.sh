#!/usr/bin/env bash
# run-jupyter-notebook.sh
# Jupyter Notebook을 지정한 포트(<port>, 기본 8888)로 실행한다.
# jupyter 관련 패키지가 없으면 uv add 로 자동으로 추가한다.

set -euo pipefail

PORT="${1:-8888}"

# 프로젝트 루트에서 실행 (스크립트 위치 기준)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# uv 존재 여부 확인
if ! command -v uv >/dev/null 2>&1; then
  echo "❌ 'uv' 가 설치되어 있지 않습니다. https://docs.astral.sh/uv/ 참고하여 설치하세요."
  exit 1
fi

# jupyter 실행에 필요한 패키지 목록
REQUIRED_PKGS=(
  "jupyter"
  "notebook"
  "ipykernel"
)

# pyproject.toml / uv.lock 기준으로 패키지 존재 여부 확인
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! uv pip show "$pkg" >/dev/null 2>&1; then
    MISSING_PKGS+=("$pkg")
  fi
done

# 누락된 패키지가 있으면 uv add 로 추가
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  echo "➕ 누락된 패키지 추가: ${MISSING_PKGS[*]}"
  uv add "${MISSING_PKGS[@]}"
fi

# jupyter가 이 프로젝트의 가상환경을 ipykernel 로 인식할 수 있도록 등록
KERNEL_DISPLAY_NAME="Python (learning-sft-and-rl)"
KERNEL_NAME="learning-sft-and-rl"
if ! uv run jupyter kernelspec list 2>/dev/null | grep -q "$KERNEL_NAME"; then
  echo "🔧 ipykernel 등록: $KERNEL_NAME"
  uv run ipython kernel install --user --name="$KERNEL_NAME" --display-name="$KERNEL_DISPLAY_NAME" >/dev/null 2>&1 || true
fi

echo "🚀 Jupyter Notebook 시작 — http://localhost:${PORT}"
exec uv run jupyter notebook --port="$PORT" --no-browser
