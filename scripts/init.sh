#!/usr/bin/env sh
set -eu

info() {
  printf '%s\n' "$*"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_if_available() {
  desc="$1"
  shift
  info "==> $desc"
  "$@"
}

make_has_target() {
  [ -f Makefile ] && has_cmd make && make -qp 2>/dev/null | grep -q "^$1:"
}

detect_node_pm() {
  if [ -f pnpm-lock.yaml ] && has_cmd pnpm; then
    printf '%s\n' pnpm
  elif [ -f yarn.lock ] && has_cmd yarn; then
    printf '%s\n' yarn
  elif [ -f package-lock.json ] && has_cmd npm; then
    printf '%s\n' npm
  elif [ -f package.json ]; then
    if has_cmd pnpm; then
      printf '%s\n' pnpm
    elif has_cmd yarn; then
      printf '%s\n' yarn
    elif has_cmd npm; then
      printf '%s\n' npm
    else
      printf '%s\n' ""
    fi
  else
    printf '%s\n' ""
  fi
}

bootstrap_make() {
  if make_has_target init; then
    run_if_available "running make init" make init
  elif make_has_target setup; then
    run_if_available "running make setup" make setup
  elif [ -f Makefile ]; then
    info "Makefile found, but no init/setup target detected."
  fi
}

bootstrap_node() {
  pm="$(detect_node_pm)"
  if [ -n "$pm" ]; then
    case "$pm" in
      pnpm)
        run_if_available "installing JavaScript/TypeScript dependencies with pnpm" pnpm install
        ;;
      yarn)
        if [ -f yarn.lock ]; then
          run_if_available "installing JavaScript/TypeScript dependencies with yarn" yarn install --frozen-lockfile
        else
          run_if_available "installing JavaScript/TypeScript dependencies with yarn" yarn install
        fi
        ;;
      npm)
        if [ -f package-lock.json ]; then
          run_if_available "installing JavaScript/TypeScript dependencies with npm ci" npm ci
        else
          run_if_available "installing JavaScript/TypeScript dependencies with npm install" npm install
        fi
        ;;
    esac
  elif [ -f package.json ]; then
    info "package.json found, but npm/pnpm/yarn is unavailable."
  else
    info "No package.json found; skipping JavaScript/TypeScript dependency install."
  fi
}

bootstrap_php() {
  if [ -f composer.json ]; then
    if has_cmd composer; then
      if [ -f composer.lock ]; then
        run_if_available "installing PHP dependencies with composer install" composer install --no-interaction --prefer-dist
      else
        run_if_available "installing PHP dependencies with composer install" composer install --no-interaction
      fi
    else
      info "composer.json found, but composer is unavailable."
    fi
  else
    info "No composer.json found; skipping PHP dependency install."
  fi
}

bootstrap_go() {
  if [ -f go.mod ]; then
    if has_cmd go; then
      run_if_available "downloading Go modules" go mod download
    else
      info "go.mod found, but go is unavailable."
    fi
  else
    info "No go.mod found; skipping Go module download."
  fi
}

bootstrap_rust() {
  if [ -f Cargo.toml ]; then
    if has_cmd cargo; then
      if [ -f Cargo.lock ]; then
        run_if_available "fetching Rust dependencies with cargo" cargo fetch --locked
      else
        run_if_available "fetching Rust dependencies with cargo" cargo fetch
      fi
    else
      info "Cargo.toml found, but cargo is unavailable."
    fi
  else
    info "No Cargo.toml found; skipping Rust dependency fetch."
  fi
}

info "AI development harness bootstrap"
info "Repository: $(pwd)"
info ""

missing=0
for tool in git sh; do
  if has_cmd "$tool"; then
    info "found: $tool"
  else
    info "missing required tool: $tool"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  info ""
  info "Install missing required tools and rerun scripts/init.sh."
  exit 1
fi

bootstrap_make
bootstrap_node
bootstrap_php
bootstrap_go
bootstrap_rust

info ""
info "Next steps:"
info "1. Read AGENTS.md, CLAUDE.md, docs/architecture.md, docs/conventions.md, and docs/setup.md."
info "2. Create a task from tasks/task-template.md."
info "3. Run scripts/verify.sh before declaring work complete."
