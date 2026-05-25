#!/usr/bin/env sh
set -eu

info() {
  printf '%s\n' "$*"
}

info "Review started"
info ""

if [ ! -x scripts/verify.sh ]; then
  info "FAIL: scripts/verify.sh is missing or not executable."
  exit 1
fi

scripts/verify.sh

info ""
info "==> git diff summary"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short -- .
  info ""
  git diff --stat -- .
else
  info "SKIP: git is unavailable or this is not a git worktree."
fi

info ""
info "Review questions:"
info "1. Does it satisfy acceptance criteria?"
info "2. Are tests meaningful?"
info "3. Did we avoid scope creep?"
info "4. Are docs/progress updated?"
info "5. Are there security or performance risks?"
