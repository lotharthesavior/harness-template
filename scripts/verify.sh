#!/usr/bin/env sh
set -u

failures=0
ran=0
skipped=0

info() {
  printf '%s\n' "$*"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

mark_skip() {
  skipped=$((skipped + 1))
  info "SKIP: $*"
}

run_check() {
  name="$1"
  shift
  ran=$((ran + 1))
  info ""
  info "==> $name"
  if "$@"; then
    info "PASS: $name"
  else
    code=$?
    failures=$((failures + 1))
    info "FAIL: $name (exit $code)"
  fi
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

json_has_script() {
  file="$1"
  script="$2"
  [ -f "$file" ] || return 1
  if has_cmd node; then
    node -e "const p=require('./$file'); process.exit(p.scripts && p.scripts['$script'] ? 0 : 1)"
  else
    grep -q "\"$script\"[[:space:]]*:" "$file"
  fi
}

run_node_script() {
  pm="$1"
  script="$2"
  case "$pm" in
    pnpm) run_check "node:$script" pnpm run "$script" ;;
    yarn) run_check "node:$script" yarn run "$script" ;;
    npm) run_check "node:$script" npm run "$script" ;;
  esac
}

run_composer_script() {
  script="$1"
  run_check "php:$script" composer run-script "$script"
}

has_shell_files() {
  find . \
    \( -path './.git' -o -path './.venv' -o -path './vendor' -o -path './node_modules' -o -path './target' \) -prune \
    -o -type f \( -name '*.sh' -o -path './scripts/*' \) -print -quit | grep -q .
}

run_make_or_skip() {
  target="$1"
  if make_has_target "$target"; then
    run_check "make:$target" make "$target"
    return 0
  fi
  return 1
}

verify_format() {
  if run_make_or_skip format || run_make_or_skip fmt; then
    return
  fi

  ran_any=0

  pm="$(detect_node_pm)"
  if [ -n "$pm" ] && json_has_script package.json format; then
    run_node_script "$pm" format
    ran_any=1
  elif [ -n "$pm" ] && json_has_script package.json "format:check"; then
    run_node_script "$pm" "format:check"
    ran_any=1
  fi

  if [ -f go.mod ] && has_cmd go; then
    run_check "go:fmt" sh -c 'out=$(find . -path ./.git -prune -o -path ./vendor -prune -o -name "*.go" -exec gofmt -l {} +); test -z "$out"'
    ran_any=1
  elif [ -f go.mod ]; then
    mark_skip "go.mod found, but go is unavailable for format check"
    ran_any=1
  fi

  if [ -f Cargo.toml ] && has_cmd cargo; then
    run_check "rust:fmt" cargo fmt --check
    ran_any=1
  elif [ -f Cargo.toml ]; then
    mark_skip "Cargo.toml found, but cargo is unavailable for format check"
    ran_any=1
  fi

  if [ "$ran_any" -eq 0 ]; then
    mark_skip "no formatter/check target detected"
  fi
}

verify_lint() {
  if run_make_or_skip lint; then
    return
  fi

  ran_any=0

  pm="$(detect_node_pm)"
  if [ -n "$pm" ] && json_has_script package.json lint; then
    run_node_script "$pm" lint
    ran_any=1
  fi

  if [ -f composer.json ] && has_cmd composer && json_has_script composer.json lint; then
    run_composer_script lint
    ran_any=1
  elif [ -f composer.json ] && ! has_cmd composer; then
    mark_skip "composer.json found, but composer is unavailable for lint"
    ran_any=1
  fi

  if [ -f go.mod ] && has_cmd go; then
    run_check "go:vet" go vet ./...
    ran_any=1
  elif [ -f go.mod ]; then
    mark_skip "go.mod found, but go is unavailable for lint"
    ran_any=1
  fi

  if [ -f Cargo.toml ] && has_cmd cargo; then
    run_check "rust:clippy" cargo clippy --all-targets --all-features -- -D warnings
    ran_any=1
  elif [ -f Cargo.toml ]; then
    mark_skip "Cargo.toml found, but cargo is unavailable for lint"
    ran_any=1
  fi

  if has_shell_files; then
    if has_cmd shellcheck; then
      run_check "bash:shellcheck" find . \( -path './.git' -o -path './.venv' -o -path './vendor' -o -path './node_modules' -o -path './target' \) -prune -o -type f \( -name '*.sh' -o -path './scripts/*' \) -exec shellcheck {} +
    else
      mark_skip "shell scripts found, but shellcheck is unavailable"
    fi
    ran_any=1
  fi

  if [ "$ran_any" -eq 0 ]; then
    mark_skip "no lint target detected"
  fi
}

verify_typecheck() {
  if run_make_or_skip typecheck || run_make_or_skip type-check; then
    return
  fi

  ran_any=0

  pm="$(detect_node_pm)"
  if [ -n "$pm" ] && json_has_script package.json typecheck; then
    run_node_script "$pm" typecheck
    ran_any=1
  elif [ -n "$pm" ] && json_has_script package.json "type-check"; then
    run_node_script "$pm" "type-check"
    ran_any=1
  fi

  if [ -f composer.json ] && has_cmd composer && json_has_script composer.json analyse; then
    run_composer_script analyse
    ran_any=1
  elif [ -f composer.json ] && has_cmd composer && json_has_script composer.json analyze; then
    run_composer_script analyze
    ran_any=1
  elif [ -f composer.json ] && has_cmd composer && json_has_script composer.json phpstan; then
    run_composer_script phpstan
    ran_any=1
  elif [ -f composer.json ] && has_cmd composer && json_has_script composer.json psalm; then
    run_composer_script psalm
    ran_any=1
  elif [ -f composer.json ] && ! has_cmd composer; then
    mark_skip "composer.json found, but composer is unavailable for static analysis"
    ran_any=1
  fi

  if [ -f go.mod ] && has_cmd go; then
    run_check "go:test-compile" go test ./... -run '^$'
    ran_any=1
  fi

  if [ -f Cargo.toml ] && has_cmd cargo; then
    run_check "rust:check" cargo check --all-targets --all-features
    ran_any=1
  fi

  if [ "$ran_any" -eq 0 ]; then
    mark_skip "no typecheck/static-analysis target detected"
  fi
}

verify_test() {
  if run_make_or_skip test; then
    return
  fi

  ran_any=0

  pm="$(detect_node_pm)"
  if [ -n "$pm" ] && json_has_script package.json test; then
    case "$pm" in
      pnpm) run_check "node:test" pnpm test ;;
      yarn) run_check "node:test" yarn test ;;
      npm) run_check "node:test" npm test ;;
    esac
    ran_any=1
  fi

  if [ -f composer.json ] && has_cmd composer && json_has_script composer.json test; then
    run_composer_script test
    ran_any=1
  elif [ -f composer.json ] && ! has_cmd composer; then
    mark_skip "composer.json found, but composer is unavailable for tests"
    ran_any=1
  fi

  if [ -f go.mod ] && has_cmd go; then
    run_check "go:test" go test ./...
    ran_any=1
  elif [ -f go.mod ]; then
    mark_skip "go.mod found, but go is unavailable for tests"
    ran_any=1
  fi

  if [ -f Cargo.toml ] && has_cmd cargo; then
    run_check "rust:test" cargo test --all-targets --all-features
    ran_any=1
  elif [ -f Cargo.toml ]; then
    mark_skip "Cargo.toml found, but cargo is unavailable for tests"
    ran_any=1
  fi

  if has_shell_files; then
    run_check "bash:syntax" find . \( -path './.git' -o -path './.venv' -o -path './vendor' -o -path './node_modules' -o -path './target' \) -prune -o -type f \( -name '*.sh' -o -path './scripts/*' \) -exec sh -n {} +
    ran_any=1
  fi

  if [ "$ran_any" -eq 0 ]; then
    mark_skip "no test target detected"
  fi
}

verify_build() {
  if run_make_or_skip build; then
    return
  fi

  ran_any=0

  pm="$(detect_node_pm)"
  if [ -n "$pm" ] && json_has_script package.json build; then
    run_node_script "$pm" build
    ran_any=1
  fi

  if [ -f composer.json ] && has_cmd composer && json_has_script composer.json build; then
    run_composer_script build
    ran_any=1
  elif [ -f composer.json ] && ! has_cmd composer; then
    mark_skip "composer.json found, but composer is unavailable for build"
    ran_any=1
  fi

  if [ -f go.mod ] && has_cmd go; then
    run_check "go:build" go build ./...
    ran_any=1
  elif [ -f go.mod ]; then
    mark_skip "go.mod found, but go is unavailable for build"
    ran_any=1
  fi

  if [ -f Cargo.toml ] && has_cmd cargo; then
    run_check "rust:build" cargo build --all-targets --all-features
    ran_any=1
  elif [ -f Cargo.toml ]; then
    mark_skip "Cargo.toml found, but cargo is unavailable for build"
    ran_any=1
  fi

  if [ "$ran_any" -eq 0 ]; then
    mark_skip "no build target detected"
  fi
}

info "Verification started"
info "Repository: $(pwd)"

verify_format
verify_lint
verify_typecheck
verify_test
verify_build

info ""
info "Verification summary: ran=$ran skipped=$skipped failures=$failures"

if [ "$failures" -ne 0 ]; then
  info "Verification failed."
  exit 1
fi

info "Verification passed."
