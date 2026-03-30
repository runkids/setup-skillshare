# setup-skillshare

[![Test Action](https://github.com/runkids/setup-skillshare/actions/workflows/test.yml/badge.svg)](https://github.com/runkids/setup-skillshare/actions/workflows/test.yml)

GitHub Action to install and initialize [skillshare](https://github.com/runkids/skillshare) CLI — the universal skill manager for AI coding agents.

Skillshare syncs your AI coding skills (Claude, Cursor, Codex, Gemini, and 50+ more) from a single source of truth. This action sets up skillshare in CI so you can automate skill syncing, installation, and security auditing.

## Quick Start

```yaml
name: Sync Skills
on: push

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: runkids/setup-skillshare@v1
        with:
          source: ./skills
      - run: skillshare sync
```

## Usage Examples

### Sync team skills from your repo

Your team maintains a skills repo. CI checks it out and syncs to all AI CLI targets.

```yaml
jobs:
  sync-skills:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: runkids/setup-skillshare@v1
        with:
          source: ./skills
      - run: skillshare sync
```

### Sync to specific targets with copy mode

Only sync to Claude and Cursor, using copy mode (real files instead of symlinks).

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    targets: claude,cursor
    mode: copy
- run: skillshare sync
```

### Install a tracked repo from GitHub

Install an organization's shared skills repo with `--track` for future updates.

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install your-org/skills --track
- run: skillshare sync
```

### Install specific skills from a repo

Cherry-pick individual skills by name.

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install your-org/skills --skill pdf,commit
- run: skillshare sync
```

### Cross-machine sync with git remote

Set up a git remote so skills can be pushed/pulled across machines.

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    remote: git@github.com:your-org/skills.git
- run: skillshare sync
```

### Initialize with git

Create a fresh source directory with git initialized (useful for new setups).

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    git: true
```

### Project-level skills

Use project-level skills from `.skillshare/` in the current directory.

```yaml
- uses: actions/checkout@v4
- uses: runkids/setup-skillshare@v1
  with:
    project: true
    targets: claude,cursor
- run: skillshare sync -p
```

### Pin a specific skillshare version

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    version: "0.18.3"
    source: ./skills
```

### Multi-platform matrix

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    steps:
      - uses: actions/checkout@v4
      - uses: runkids/setup-skillshare@v1
        with:
          source: ./skills
      - run: skillshare sync
```

### Private repos with SSH

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install git@github.com:your-org/private-skills.git --track
- run: skillshare sync
```

### Private repos with HTTPS token

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install https://github.com/your-org/private-skills.git --track
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
- run: skillshare sync
```

## Security Audit

Skillshare has a built-in security scanner that detects prompt injection, credential theft, obfuscation, and 100+ threat patterns in AI skills.

### Basic audit — fail CI on high severity

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    audit: true
    audit-threshold: high
```

### SARIF output for GitHub Code Scanning

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    audit: true
    audit-format: sarif
    audit-output: skillshare-audit.sarif
- uses: github/codeql-action/upload-sarif@v3
  if: always()
  with:
    sarif_file: skillshare-audit.sarif
    category: skillshare-audit
```

### Strict audit with JSON report

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    audit: true
    audit-threshold: medium
    audit-profile: strict
    audit-format: json
    audit-output: audit-results.json
```

### Audit on pull requests that modify skills

```yaml
name: Skill Validation
on:
  pull_request:
    paths: ['skills/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: runkids/setup-skillshare@v1
        with:
          source: ./skills
          audit: true
          audit-threshold: high
          audit-format: sarif
          audit-output: skillshare-audit.sarif
      - uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: skillshare-audit.sarif
          category: skillshare-audit
      - run: skillshare sync --dry-run
```

## Inputs

### Setup

| Input | Description | Default |
|-------|-------------|---------|
| `version` | Skillshare version to install (without `v` prefix) | `latest` |
| `source` | Path to skills source directory | — |
| `targets` | Comma-separated target names (e.g. `claude,cursor`) | all detected |
| `mode` | Sync mode: `merge`, `copy`, or `symlink` | `merge` |
| `git` | Initialize git in source directory | `false` |
| `remote` | Git remote URL for cross-machine sync (implies `git: true`) | — |
| `project` | Use project-level skills (`.skillshare/`) | `false` |
| `github-token` | GitHub token for API requests to avoid rate limits | `${{ github.token }}` |

### Audit

| Input | Description | Default |
|-------|-------------|---------|
| `audit` | Run security audit after setup | `false` |
| `audit-threshold` | Severity threshold: `critical`, `high`, `medium`, `low`, `info` | `high` |
| `audit-format` | Output format: `text`, `json`, `sarif`, `markdown` | `text` |
| `audit-profile` | Audit profile: `default`, `strict`, `permissive` | — |
| `audit-output` | File path to save audit results | — |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | The installed skillshare version |
| `audit-exit-code` | Audit exit code: `0` = clean, `1` = findings |

### Using outputs

```yaml
- uses: runkids/setup-skillshare@v1
  id: skillshare
  with:
    source: ./skills
    audit: true
    audit-output: audit.sarif
- run: echo "Installed ${{ steps.skillshare.outputs.version }}"
- run: echo "Audit result: ${{ steps.skillshare.outputs.audit-exit-code }}"
```

## How it works

1. **Download** skillshare binary (with retry, cached in `$RUNNER_TOOL_CACHE`)
2. **Initialize** via `skillshare init` with CI-friendly defaults
3. **Audit** (optional) with configurable threshold and output format

The action always runs `skillshare init` to create `config.yaml` — this is required before any skillshare operation. After setup, run `skillshare sync`, `skillshare install`, or any other command in subsequent steps.

### Global mode (default)

```
skillshare init --no-copy --no-skill --all-targets --no-git [--source] [--targets] [--mode] [--git] [--remote]
```

- `--no-copy` — skip interactive copy-from prompt
- `--no-skill` — skip built-in skill installation
- `--no-git` — by default (override with `git: true` or `remote`)
- `--all-targets` — by default (override with `targets`)

### Project mode (`project: true`)

```
skillshare init -p [--targets] [--mode]
```

Project mode only accepts `--targets` and `--mode`. Flags like `--source`, `--git`, `--remote` are not applicable — project skills live in `.skillshare/` of the current directory.

### Reliability

- **No `gh` CLI dependency** — version resolution uses HTTP redirect, falls back to `gh api` if available. Works on self-hosted runners.
- **Download retry** — `curl --retry 3` for transient network failures
- **Same-run cache** — binary cached in `$RUNNER_TOOL_CACHE`, skipped if already downloaded
- **Shell safety** — all inputs passed through `env:` vars, never expanded directly in shell

## Supported platforms

- `ubuntu-latest` (linux/amd64)
- `macos-latest` (darwin/arm64)
- `macos-13` (darwin/amd64)

## Alternative

You can also install skillshare without this action:

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | bash
- run: skillshare init --no-copy --all-targets --no-git --no-skill
```

## License

[MIT](LICENSE)
