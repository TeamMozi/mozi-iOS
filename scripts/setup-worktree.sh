#!/usr/bin/env bash
# Mozi worktree 세팅 스크립트.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SKIP_BUILD=0
FORCE_GENERATE=0

usage() {
  cat <<'USAGE'
사용법: scripts/setup-worktree.sh [--skip-build] [--force-generate]

Mozi git worktree 로컬 개발 세팅:
  1) detached HEAD 이면 로컬 브랜치 생성 또는 전환
  2) 없으면 main/다른 worktree 에서 Config/*.xcconfig 복사
  3) mise trust + mise install
  4) tuist generate
  5) 선택적으로 Mozi-Debug 빌드 검증

옵션:
  --skip-build       xcodebuild 검증 생략 (기본: 빌드 실행)
  --force-generate   workspace 가 있어도 tuist generate 강제 실행
  -h, --help         도움말 출력

환경변수:
  MOZI_WORKTREE_BRANCH   detached HEAD 일 때 생성/전환할 브랜치 이름
                         미지정 시 codex/<worktree-id> 사용
  MOZI_CONFIG_SOURCE     Config/*.xcconfig 복사 소스 경로
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-build) SKIP_BUILD=1; shift ;;
    --force-generate) FORCE_GENERATE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "error: 알 수 없는 옵션: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

log() {
  printf '==> %s
' "$*"
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: 필요한 명령을 찾을 수 없음: $1" >&2
    exit 1
  fi
}

need_cmd git
need_cmd mise

if [[ ! -f "$ROOT/.mise.toml" || ! -f "$ROOT/Workspace.swift" ]]; then
  echo "error: Mozi 저장소 루트에서 실행하세요 (.mise.toml 또는 Workspace.swift 없음)" >&2
  exit 1
fi

is_branch_checked_out_elsewhere() {
  local branch="$1"
  local target="refs/heads/${branch}"
  local worktree=""
  local checked_out_branch=""

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        worktree="${line#worktree }"
        checked_out_branch=""
        ;;
      branch\ *)
        checked_out_branch="${line#branch }"
        ;;
      "")
        if [[ -n "$worktree" && -n "$checked_out_branch" && "$worktree" != "$ROOT" && "$checked_out_branch" == "$target" ]]; then
          return 0
        fi
        worktree=""
        checked_out_branch=""
        ;;
    esac
  done < <(git worktree list --porcelain; printf '\n')

  return 1
}

default_worktree_branch() {
  local parent leaf candidate

  parent="$(basename "$(dirname "$ROOT")")"
  leaf="$(basename "$ROOT")"

  # Codex worktree 경로: ~/.codex/worktrees/<id>/<repo>
  if [[ "$parent" =~ ^[0-9a-f]{4,}$ ]]; then
    printf 'codex/%s\n' "$parent"
    return 0
  fi

  # 그 외 worktree 는 폴더명 기반 fallback
  candidate="$(printf '%s\n' "$leaf" | tr -c 'A-Za-z0-9._-' '-')"
  candidate="${candidate##-}"
  candidate="${candidate%%-}"
  if [[ -z "$candidate" ]]; then
    candidate="$(git rev-parse --short HEAD)"
  fi
  printf 'codex/%s\n' "$candidate"
}

unique_branch_name() {
  local base="$1"
  local candidate="$base"
  local n=2

  while true; do
    if is_branch_checked_out_elsewhere "$candidate"; then
      candidate="${base}-${n}"
      n=$((n + 1))
      continue
    fi

    # 다른 worktree 가 안 잡고 있으면 기존 로컬 브랜치도 재사용
    printf '%s\n' "$candidate"
    return 0
  done
}

ensure_branch() {
  local current branch
  current="$(git rev-parse --abbrev-ref HEAD)"

  if [[ "$current" != "HEAD" ]]; then
    log "이미 브랜치에 있음: $current"
    return 0
  fi

  if [[ -n "${MOZI_WORKTREE_BRANCH:-}" ]]; then
    branch="$MOZI_WORKTREE_BRANCH"
    if is_branch_checked_out_elsewhere "$branch"; then
      echo "error: 브랜치 '${branch}' 가 다른 worktree 에서 사용 중입니다." >&2
      echo "       MOZI_WORKTREE_BRANCH 를 다른 이름으로 지정하세요." >&2
      exit 1
    fi
  else
    branch="$(unique_branch_name "$(default_worktree_branch)")"
  fi

  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    log "기존 브랜치로 전환: $branch"
    git switch "$branch"
  else
    log "detached HEAD → 브랜치 생성: $branch"
    git switch -c "$branch"
  fi
}

find_config_source() {
  if [[ -n "${MOZI_CONFIG_SOURCE:-}" ]]; then
    printf '%s
' "$MOZI_CONFIG_SOURCE"
    return 0
  fi

  local path
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ "$path" == "$ROOT" ]]; then
      continue
    fi
    if [[ -f "$path/Config/Debug.xcconfig" && -f "$path/Config/Release.xcconfig" ]]; then
      printf '%s
' "$path"
      return 0
    fi
  done < <(git worktree list --porcelain | awk '/^worktree / { print substr($0, 10) }')

  return 1
}

ensure_configs() {
  mkdir -p "$ROOT/Config"

  local missing=0
  [[ -f "$ROOT/Config/Debug.xcconfig" ]] || missing=1
  [[ -f "$ROOT/Config/Release.xcconfig" ]] || missing=1

  if [[ "$missing" -eq 0 ]]; then
    log "Config 이미 있음"
    return 0
  fi

  local source
  if ! source="$(find_config_source)"; then
    if [[ -f "$ROOT/Config/Example.xcconfig" ]]; then
      log "다른 worktree config 없음; Config/Example.xcconfig 에서 복사"
      [[ -f "$ROOT/Config/Debug.xcconfig" ]] || cp "$ROOT/Config/Example.xcconfig" "$ROOT/Config/Debug.xcconfig"
      [[ -f "$ROOT/Config/Release.xcconfig" ]] || cp "$ROOT/Config/Example.xcconfig" "$ROOT/Config/Release.xcconfig"
      return 0
    fi

    cat >&2 <<'ERR'
error: Config/Debug.xcconfig 또는 Config/Release.xcconfig 가 없습니다.

이 파일들은 gitignore 대상입니다. 아래 중 하나로 준비하세요:
  - Config/ 가 있는 main/다른 worktree 가 있는 상태에서 이 스크립트 실행
  - MOZI_CONFIG_SOURCE=/path/to/main 지정
  - Config/Example.xcconfig 를 Debug/Release 로 직접 복사
ERR
    exit 1
  fi

  log "로컬 config 복사: $source"
  [[ -f "$ROOT/Config/Debug.xcconfig" ]] || cp "$source/Config/Debug.xcconfig" "$ROOT/Config/Debug.xcconfig"
  [[ -f "$ROOT/Config/Release.xcconfig" ]] || cp "$source/Config/Release.xcconfig" "$ROOT/Config/Release.xcconfig"
}

ensure_tools() {
  log "mise config trust"
  mise trust "$ROOT" >/dev/null

  log "mise 로 툴 설치"
  mise install
}

ensure_project() {
  if [[ "$FORCE_GENERATE" -eq 0 && -d "$ROOT/Mozi.xcworkspace" ]]; then
    log "Mozi.xcworkspace 이미 있음; generate 생략 (--force-generate 로 재생성)"
    return 0
  fi

  log "Tuist 로 Xcode 프로젝트 생성"
  mise exec -- tuist generate --no-open
}

verify_build() {
  if [[ "$SKIP_BUILD" -eq 1 ]]; then
    log "빌드 검증 생략"
    return 0
  fi

  if [[ ! -d "$ROOT/Mozi.xcworkspace" ]]; then
    echo "error: generate 이후에도 Mozi.xcworkspace 가 없음" >&2
    exit 1
  fi

  log "Mozi-Debug 빌드 검증"
  xcodebuild     -workspace "$ROOT/Mozi.xcworkspace"     -scheme Mozi-Debug     -destination 'generic/platform=iOS Simulator'     -skipMacroValidation     -derivedDataPath "$ROOT/.derivedData"     build
}

log "Mozi worktree 세팅 시작: $ROOT"
ensure_branch
ensure_configs
ensure_tools
ensure_project
verify_build
log "worktree 세팅 완료"
