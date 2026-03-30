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

### Install from a remote skill repo

```yaml
- uses: runkids/setup-skillshare@v1
- run: skillshare install your-org/skills --yes
```

### Initialize with git

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    git: true
```

### Cross-machine sync with git remote

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    remote: git@github.com:your-org/skills.git
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

| Input | Description | Default |
|-------|-------------|---------|
| `version` | Skillshare version to install (without `v` prefix) | `latest` |
| `source` | Path to skills source directory | — |
| `targets` | Comma-separated target names (e.g. `claude,cursor`) | all detected |
| `mode` | Sync mode: `merge`, `copy`, or `symlink` | `merge` |
| `git` | Initialize git in source directory | `false` |
| `remote` | Git remote URL for cross-machine sync (implies `git: true`) | — |
| `github-token` | GitHub token for API requests to avoid rate limits | `${{ github.token }}` |

## How it works

1. Downloads and installs the skillshare binary
2. Runs `skillshare init` with CI-friendly defaults (`--no-copy --no-skill`)
3. Configures source, targets, and sync mode based on your inputs

After setup, run `skillshare sync`, `skillshare install`, or any other command in subsequent steps.

## Alternative

You can also install skillshare directly without this action:

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | bash
```
