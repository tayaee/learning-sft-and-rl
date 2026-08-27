#!/bin/bash
# scripts_common.sh — smoke|full 모드 검증 및 _make 조건부 빌드(Make 스타일) 공통 함수

FORCE="${FORCE:-0}"

parse_flags() {
  for arg in "$@"; do
    case "$arg" in
      -f|--force)
        FORCE=1
        ;;
    esac
  done
}

require_mode() {
  local mode=""
  local default_mode="${1:-}"
  local script="${2:-$0}"

  for arg in "$@"; do
    case "$arg" in
      -f|--force)
        ;;
      smoke|full)
        mode="$arg"
        ;;
    esac
  done

  if [ -z "$mode" ]; then
    if [ "$default_mode" = "smoke" ] || [ "$default_mode" = "full" ]; then
      mode="$default_mode"
    else
      echo "ERROR: 사용법: $script smoke|full [-f]  (smoke 또는 full 을 반드시 지정하세요)" >&2
      exit 1
    fi
  fi
  echo "$mode"
}

_make() {
  local target="$1"
  shift
  local deps=()
  while [ $# -gt 0 ] && [ "$1" != "--" ]; do
    deps+=("$1")
    shift
  done
  [ "$1" = "--" ] && shift

  local need_build=0

  if [ "${FORCE:-0}" = "1" ]; then
    need_build=1
  elif [ ! -e "$target" ]; then
    need_build=1
  else
    local target_mtime_ref="$target"
    if [ -d "$target" ]; then
      if [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
        need_build=1
      fi
      for keyfile in "merged/model.safetensors" "adapter_model.safetensors" "model.safetensors" "comparison-table.md" "bin/python"; do
        if [ -e "$target/$keyfile" ]; then
          target_mtime_ref="$target/$keyfile"
          break
        fi
      done
    elif [ ! -s "$target" ]; then
      need_build=1
    fi

    if [ "$need_build" = "0" ]; then
      for dep in "${deps[@]}"; do
        [ -z "$dep" ] && continue
        if [ -e "$dep" ]; then
          local dep_mtime_ref="$dep"
          if [ -d "$dep" ]; then
            for keyfile in "merged/model.safetensors" "adapter_model.safetensors" "model.safetensors" "comparison-table.md" "bin/python"; do
              if [ -e "$dep/$keyfile" ]; then
                dep_mtime_ref="$dep/$keyfile"
                break
              fi
            done
          fi
          if [ "$dep_mtime_ref" -nt "$target_mtime_ref" ]; then
            need_build=1
            break
          fi
        fi
      done
    fi
  fi

  if [ "$need_build" = "0" ]; then
    echo "INFO: [cache] $target 이(가) 최신 상태이므로 건너뜁니다. (재생성: -f)"
    return 0
  fi

  if [ $# -gt 0 ]; then
    "$@"
    return $?
  fi
  return 0
}
