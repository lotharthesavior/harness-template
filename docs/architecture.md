# Architecture

## Current State

This repository currently contains AI-agent configuration and harness files. Application source code, runtime entrypoints, package manifests, and deployment configuration are not yet present or have not been identified.

Known repo items:

- `AGENTS.md`, `CLAUDE.md`, `docs/`, `tasks/`, `scripts/`, and `progress.md`: AI development harness.
- `.github/workflows/`: CI automation.
- `.gitignore` and `SECURITY.md`: repository hygiene and security guidance.

Known local-only items:

- `.codex/`: local Codex/GSD agent configuration and installed helper agents.
- `.agents/`: local agent runtime files when present.
- `.venv/`: local Python virtual environment.

Unknown placeholders:

- Product/domain architecture: unknown.
- Runtime language/framework: unknown.
- Main application entrypoint: unknown.
- Persistence layer: unknown.
- External services: unknown.
- Deployment target: unknown.

Update this document as soon as source modules or runtime boundaries are introduced.

## Module Boundaries

Until application code exists, use these boundaries:

- `docs/`: project documentation and architectural decisions.
- `tasks/`: task definitions and acceptance criteria.
- `scripts/`: local automation and verification sensors.
- `.github/workflows/`: CI automation.

When application code is added, document each module with:

- Responsibility.
- Public interface.
- Dependencies allowed.
- Dependencies forbidden.
- Test strategy.

## Dependency Rules

- Follow existing project patterns first.
- Keep domain logic independent of UI, transport, and storage details where possible.
- Avoid circular dependencies.
- Keep scripts idempotent and safe to rerun.
- Do not introduce new runtime dependencies without a clear reason and setup documentation.
- Do not require secrets for local verification or CI.

## Architectural Decision Log

Add dated decisions here as the system takes shape.

- 2026-05-24: Added an AI development harness with guides, verification scripts, progress tracking, and CI defaults. Application architecture remains unknown.
- 2026-05-25: Classified `.codex/`, `.agents/`, and `.venv/` as local-only artifacts because they can contain machine-specific paths, hooks, generated state, or installed dependencies.
