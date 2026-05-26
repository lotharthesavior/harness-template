# Task: <short title>

## Goal

Describe the outcome this task must achieve.

## Context

Link relevant docs, files, prior decisions, user requirements, and known constraints.

Harness root: `<path to this harness>`

Target project root: `<path to project being changed>`

State location: `.harness-db/<project-or-run-id>/` or another ignored harness database path.

## Acceptance Criteria

- [ ] Observable outcome 1.
- [ ] Observable outcome 2.
- [ ] Verification command passes or documented exception exists.

## Constraints

- Scope limits.
- Compatibility requirements.
- Files or areas that should not be changed.
- Security, performance, or migration constraints.
- Project-specific documents, task notes, run progress, and generated indexes are local database records. Keep them in ignored harness database state, not tracked template files.
- Use `scripts/init.sh --project <path>`, `scripts/verify.sh --project <path>`, and `scripts/review.sh --project <path>` when the target project is outside the harness root.

## Implementation Plan

1. Read relevant docs and source files.
2. Make the smallest viable change.
3. Add or update tests/docs as needed.
4. Update `progress.md`.

## Verification Plan

- Run `scripts/verify.sh`.
- Run targeted tests or commands relevant to this task.
- Inspect `git diff`.

## Rollback Notes

Describe how to revert the change safely, including data or migration considerations if applicable.
