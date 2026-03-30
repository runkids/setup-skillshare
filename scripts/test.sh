#!/usr/bin/env bash
# Assertion tests for setup-skillshare action
set -euo pipefail

PASS=0
FAIL=0

assert() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "✓ $description"
    ((PASS++))
  else
    echo "✗ $description"
    ((FAIL++))
  fi
}

assert_contains() {
  local description="$1"
  local actual="$2"
  local expected="$3"
  if echo "$actual" | grep -q "$expected"; then
    echo "✓ $description"
    ((PASS++))
  else
    echo "✗ $description (expected '$expected' in '$actual')"
    ((FAIL++))
  fi
}

# --- Tests ---

echo "=== setup-skillshare test suite ==="
echo ""

# Binary installed
assert "skillshare binary exists in PATH" command -v skillshare

# Version output
VERSION_OUTPUT=$(skillshare version 2>&1 || true)
assert_contains "skillshare version outputs version" "$VERSION_OUTPUT" "skillshare"

# Config created by init
assert "config.yaml exists" test -f ~/.config/skillshare/config.yaml

# Source directory
assert "source directory exists" test -d ~/.config/skillshare/skills

# --- Results ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
