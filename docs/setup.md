# Setup

## Prerequisites

Required:

- POSIX-compatible shell.
- `git`.

Optional, depending on project files:

- `make` when a `Makefile` exists.
- Node.js and one of `npm`, `pnpm`, or `yarn` when `package.json` exists.
- `composer` and PHP when `composer.json` exists.
- Go when `go.mod` exists.
- Rust and Cargo when `Cargo.toml` exists.
- `shellcheck` for stronger Bash/shell linting.
- Other language runtimes as documented by future project code.

## Bootstrap

From the repository root:

```sh
scripts/init.sh
```

The bootstrap script is safe and idempotent. It checks available tools, installs dependencies when a known lockfile or manifest is present, and prints next steps.

To bootstrap a separate target project directory from this harness:

```sh
scripts/init.sh --project /path/to/project
```

Or:

```sh
HARNESS_TARGET_ROOT=/path/to/project scripts/init.sh
```

Detected bootstrap inputs:

- `Makefile`: runs `make init` or `make setup` when either target exists.
- `package.json`: installs JavaScript/TypeScript dependencies with `pnpm`, `yarn`, or `npm`.
- `composer.json`: installs PHP dependencies with Composer.
- `go.mod`: downloads Go modules with `go mod download`.
- `Cargo.toml`: fetches Rust dependencies with Cargo.

## Environment Variables

No required environment variables are currently known.

Optional harness variables:

- `HARNESS_TARGET_ROOT`: target project directory for `scripts/init.sh`, `scripts/verify.sh`, and `scripts/review.sh` when `--project` is not passed.

When environment variables are introduced, document each one here:

- Name.
- Required or optional.
- Example value.
- Whether it is safe for local development.
- Where it is used.

Do not commit real secrets.

Local-only files such as `.env`, `.venv/`, `.codex/`, `.agents/`, `.harness-db/`, caches, and private keys are ignored by default.

Project registries, task notes, generated indexes, and per-project progress documents belong in `.harness-db/` or another ignored local database directory. Treat them as database content owned by the local harness installation, not as tracked template files.

## Run

No application run command is currently known.

When an entrypoint is introduced, document it here. Prefer project-native commands such as:

```sh
make run
```

or:

```sh
npm run dev
```

## Test, Lint, Typecheck, Format, Build

Use the verification sensor:

```sh
scripts/verify.sh
```

To verify a separate target project directory:

```sh
scripts/verify.sh --project /path/to/project
```

To review a separate target project directory:

```sh
scripts/review.sh --project /path/to/project
```

The review script runs verification in the target project root and prints target git changes separately from harness git changes.

`scripts/verify.sh` automatically detects common Make, JavaScript/TypeScript, PHP, Go, Rust, and Bash commands. It runs available checks and skips missing checks clearly.

Detection order:

- Make targets override generic detection when targets such as `format`, `lint`, `typecheck`, `test`, or `build` exist.
- JavaScript/TypeScript projects use matching `package.json` scripts through `pnpm`, `yarn`, or `npm`.
- PHP projects use Composer scripts such as `lint`, `analyse`/`analyze`, `phpstan`, `psalm`, `test`, and `build`.
- Go projects use `gofmt`, `go vet`, `go test`, and `go build`.
- Rust projects use `cargo fmt --check`, `cargo clippy`, `cargo check`, `cargo test`, and `cargo build`.
- Bash/shell files use `sh -n`; `shellcheck` runs when available.

Manual command placeholders:

```sh
make test
make lint
make typecheck
make build
```

or:

```sh
npm test
npm run lint
npm run typecheck
npm run build
```

or:

```sh
composer run-script test
go test ./...
cargo test --all-targets --all-features
sh -n scripts/*.sh
```

Replace these placeholders with exact project commands when tooling is added.
