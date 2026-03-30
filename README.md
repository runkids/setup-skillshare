# setup-skillshare

GitHub Action to install and initialize [skillshare](https://github.com/runkids/skillshare) CLI for managing AI coding skills.

## Usage

### Sync team skills from your repo

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

### Sync to specific targets

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    targets: claude,cursor
    mode: copy
```

### Install tracked repo from GitHub

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install your-org/skills --track
- run: skillshare sync
```

### Cross-machine sync with git remote

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    remote: git@github.com:your-org/skills.git
```

### Security audit in CI

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

### Strict audit profile

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    source: ./skills
    audit: true
    audit-threshold: medium
    audit-profile: strict
```

### Pin a specific version

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    version: "0.18.3"
    source: ./skills
```

### Use in a matrix

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
| `github-token` | GitHub token for API requests to avoid rate limits | `${{ github.token }}` |

### Audit

| Input | Description | Default |
|-------|-------------|---------|
| `audit` | Run security audit after setup | `false` |
| `audit-threshold` | Severity threshold: `critical`, `high`, `medium`, `low`, `info` | `high` |
| `audit-format` | Output format: `text`, `json`, `sarif`, `markdown` | `text` |
| `audit-profile` | Audit profile: `default`, `strict`, `permissive` | — |
| `audit-output` | File path to save audit results | — |

## How it works

1. Downloads and installs the skillshare binary
2. Runs `skillshare init` with CI-friendly defaults (`--no-copy --no-skill`)
3. Configures source, targets, and sync mode based on your inputs
4. Optionally runs `skillshare audit` with your threshold and format

After setup, run `skillshare sync`, `skillshare install`, or any other command in subsequent steps.

## Alternative

You can also install skillshare directly without this action:

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | bash
```
