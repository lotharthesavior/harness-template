# Progress

## Current Goal

Fix the CI verification failure caused by ShellCheck SC2016 in `scripts/verify.sh`.

## Decisions

- Keep this file current during each task.
- Record only decisions that affect future implementation, verification, setup, or architecture.
- Move completed task details out of this file when they stop being useful for the next run.

## Active Plan

Phase: Planning

Goal: make the harness template support orchestrating work in separate project directories while keeping project state as local database content owned by the harness.

Non-goals: add application code, introduce a persistent database engine, or require target projects to adopt this template.

Acceptance criteria:

- Harness scripts can bootstrap, verify, and review an explicit target project directory.
- Documentation distinguishes harness root, target project root, and local database state.
- Project-related run documents are documented as ignored local database content, not tracked template files.
- `scripts/verify.sh` runs and the result is recorded.

Implementation plan:

1. Preserve existing local changes in `progress.md` and `scripts/verify.sh`.
2. Add target-root option handling to harness scripts.
3. Ignore local harness database directories in `.gitignore`.
4. Update README, setup, architecture, conventions, operating guides, and task template.
5. Run verification and inspect the diff.

Verification plan:

- Run `scripts/verify.sh`.
- Run `scripts/review.sh`.
- Inspect `git diff`.

Known risks:

- Local verification depends on optional tools available in the current environment.
- Existing target projects may have repo-specific setup that generic detection cannot infer.

## Completed Steps

- Template initialized with agent guides, docs, task template, bootstrap script, verification script, review script, CI workflow, security guidance, and repository hygiene defaults.
- Planning: read required harness docs, active task template, `progress.md`, and inspected `scripts/verify.sh`.
- Build: replaced the inline `sh -c` Go format check with a named `check_go_format` function to avoid ShellCheck SC2016 while preserving behavior.
- Review: ran verification and review scripts, inspected the diff, and confirmed the change is limited to `scripts/verify.sh` and `progress.md`.
- Planning: read required harness docs, task template, README, scripts, `.gitignore`, and current local diffs for cross-directory orchestration support.
- Build: added target-project support to `scripts/init.sh`, `scripts/verify.sh`, and `scripts/review.sh` with `--project PATH` and `HARNESS_TARGET_ROOT`.
- Build: documented `.harness-db/` as ignored local database state for project registries, task notes, progress, indexes, and project documents.
- Review: ran syntax checks, verification, review, and target-option smoke checks.

## Next Steps

- Confirm whether to add a richer local database schema after the first real target project is registered.

## Blockers

- None.

## Verification History

- 2026-05-25: `scripts/verify.sh` passed locally. Result: ran=1 skipped=4 failures=0. Note: local `shellcheck` is unavailable, so the ShellCheck path was skipped locally.
- 2026-05-25: `scripts/review.sh` passed locally. It reran `scripts/verify.sh` with the same result and printed a diff summary for `progress.md` and `scripts/verify.sh`.
- 2026-05-25: `sh -n scripts/init.sh`, `sh -n scripts/verify.sh`, and `sh -n scripts/review.sh` passed.
- 2026-05-25: `scripts/verify.sh` passed locally. Result: ran=1 skipped=4 failures=0. Note: local `shellcheck` is unavailable, so the ShellCheck path was skipped locally.
- 2026-05-25: `scripts/review.sh` passed locally. It reran `scripts/verify.sh` with the same result and printed target git diff summary.
- 2026-05-25: `scripts/init.sh --project .`, `scripts/verify.sh --project .`, `scripts/review.sh --project .`, and `HARNESS_TARGET_ROOT=. scripts/verify.sh` passed as target-root smoke checks.
- 2026-05-25: Final `scripts/verify.sh` passed locally after updating `progress.md`. Result: ran=1 skipped=4 failures=0. Note: local `shellcheck` is unavailable.
