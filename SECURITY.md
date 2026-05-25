# Security

## Repository Hygiene

- Do not commit secrets, credentials, private keys, local tokens, or real `.env` files.
- Keep local runtime artifacts out of git, including `.venv/`, `.codex/`, `.agents/`, caches, and dependency folders.
- Use `.env.example` for documented configuration shape only.
- CI and local verification must not require production credentials.

## Agent Harness Notes

This template keeps portable harness files in the repository: guides, docs, task templates, scripts, and CI.

Local agent installations can contain absolute paths, user-specific hooks, generated manifests, and machine state. Those files are ignored by default and should be regenerated per workstation rather than committed.

## Before Commit Or PR

Run:

```sh
scripts/verify.sh
scripts/review.sh
```

Also inspect the staged set:

```sh
git diff --cached --stat
git diff --cached --name-only
```
