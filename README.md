# AI Development Harness Template

This template provides an AI development harness so work can be planned, implemented, verified, reviewed, and resumed safely.

## Start Here

From the project root, run:

```sh
scripts/init.sh
```

Then read:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/architecture.md`
- `docs/conventions.md`
- `docs/setup.md`
- `progress.md`

These files explain how agents and humans should work in this repo.

## Daily Workflow

1. Define the task.
   - Copy `tasks/task-template.md` into a new task note, or use it as a checklist.
   - Write the goal, context, acceptance criteria, constraints, implementation plan, verification plan, and rollback notes.

2. Plan before coding.
   - Read the relevant docs and files.
   - Break work into small steps.
   - Record the current goal and plan in `progress.md`.

3. Build in small steps.
   - Keep changes scoped to the task.
   - Follow existing patterns first.
   - Update tests and docs when behavior changes.
   - Update `progress.md` after each meaningful step.

4. Verify before calling work complete.
   - Run:

```sh
scripts/verify.sh
```

5. Review before handoff or PR.
   - Run:

```sh
scripts/review.sh
```

## Important Rules

- Do not declare success without running `scripts/verify.sh`.
- Keep planning, building, and reviewing as separate phases.
- Do not assume secrets exist locally or in CI.
- Do not delete existing files unless the task explicitly requires it.
- Record commands run and results in `progress.md` and handoff notes.

## Project Structure

```text
.github/workflows/ci.yml  CI verification
.gitignore                Repo hygiene for local artifacts, secrets, and generated output
AGENTS.md                 Agent operating guide
CLAUDE.md                 Claude-specific project instructions
SECURITY.md               Security and repository hygiene guidance
docs/architecture.md      Architecture notes and module boundaries
docs/conventions.md       Coding, testing, logging, and security conventions
docs/setup.md             Local setup and command documentation
progress.md               Current goal, decisions, steps, blockers, verification history
scripts/init.sh           Safe bootstrap script
scripts/verify.sh         Local verification sensor
scripts/review.sh         Review helper
tasks/task-template.md    Reusable task template
```

## Verification

Use:

```sh
scripts/verify.sh
```

The script detects common project tooling:

- `Makefile` targets when available.
- `package.json` with `npm`, `pnpm`, or `yarn` when available.
- `composer.json` for PHP projects.
- `go.mod` for Go projects.
- `Cargo.toml` for Rust projects.
- Bash/shell files, including `scripts/*.sh`.

It attempts formatter/check, lint, typecheck, tests, and build. Missing checks are reported as explicit skips.

## CI

CI is defined in `.github/workflows/ci.yml`.

It runs:

```sh
scripts/init.sh
scripts/verify.sh
```

CI uses safe defaults and does not assume secrets.

## Updating This Project

When source code, runtime commands, dependencies, or architecture are added:

- Update `docs/setup.md` with exact setup and run commands.
- Update `docs/architecture.md` with module boundaries and dependency rules.
- Update `docs/conventions.md` if new language/framework conventions are introduced.
- Keep `progress.md` current as work proceeds.

## Local-Only Files

Do not commit local runtime state such as `.venv/`, `.codex/`, `.agents/`, caches, real `.env` files, or private keys. Regenerate local agent tooling per workstation.
