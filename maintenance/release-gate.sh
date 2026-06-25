#!/usr/bin/env bash
# Forge release gate. Verifies the repo is consistent and safe to tag <version>.
# Run by the release workflow (and locally before tagging). Exits non-zero if the
# release isn't ready. Usage:  maintenance/release-gate.sh 3.9
set -uo pipefail
V="${1:?usage: release-gate.sh <version, e.g. 3.9>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"; cd "$HERE"

fail=0
ok(){ echo "  PASS  $1"; }
no(){ echo "  FAIL  $1"; fail=1; }
echo "Release gate for v$V"

# 1. Deterministic consistency lint must pass.
if bash maintenance/forge-lint.sh >/dev/null 2>&1; then ok "forge-lint clean"
else no "forge-lint failed — run: bash maintenance/forge-lint.sh"; fi

# 2. Version markers agree with the requested version (catches stale self-descriptions).
grep -Fq "version-$V" README.md   2>/dev/null && ok "README badge = $V"        || no "README badge != $V (bump the version- badge)"
grep -Fq "Forge v$V"  install.sh  2>/dev/null && ok "install.sh = v$V"          || no "install.sh != v$V (bump the echo line)"
grep -Fq "| v$V |"    CHANGELOG.md 2>/dev/null && ok "CHANGELOG row = v$V"        || no "CHANGELOG has no version-history row for v$V (add it + a dated section)"

# 3. Eval baseline established (the gate exists; the daily self-review keeps it green).
if grep -q '_unrun_' claude-config/evals/BASELINE.md 2>/dev/null; then
  no "BASELINE has _unrun_ — eval gate not established"
else ok "eval baseline established"; fi

# 4. Tag must not already exist.
if git rev-parse -q --verify "refs/tags/v$V" >/dev/null; then no "tag v$V already exists"; else ok "tag v$V is free"; fi

echo ""
if [ "$fail" = 0 ]; then echo "release-gate: READY to tag v$V"; exit 0
else echo "release-gate: NOT READY (fix the FAILs above)"; exit 1; fi
