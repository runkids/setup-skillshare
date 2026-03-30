# setup-skillshare

GitHub Action to install [skillshare](https://github.com/runkids/skillshare) CLI for managing AI coding skills.

## Usage

```yaml
jobs:
  sync-skills:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: runkids/setup-skillshare@v1
      - run: skillshare install your-org/skills --yes
      - run: skillshare sync
```

### Pin a specific version

```yaml
- uses: runkids/setup-skillshare@v1
  with:
    version: "0.18.3"
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
      - run: skillshare version
```

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `version` | Skillshare version to install (without `v` prefix) | `latest` |
| `github-token` | GitHub token for API requests to avoid rate limits | `${{ github.token }}` |

## Alternative

You can also install skillshare directly without this action:

```yaml
- run: curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | bash
```
