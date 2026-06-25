#!/usr/bin/env bash
# Forge consistency lint — deterministic self-maintenance checks that catch the
# regression classes the June 2026 audit found by hand: stale agent/command
# counts, dead path-variable notation, the machinery log leaking into
# learnings.md, a weakened safety wall, dangling references, ungated commands,
# and an unestablished eval baseline. Runs in CI daily; exits non-zero on any
# FAIL so a bad change can't merge silently. No API key, no network.
set -uo pipefail

# Config dir: claude-config/ in the Forge repo, .claude/ in an install.
if   [ -d claude-config ]; then CFG=claude-config
elif [ -d .claude ];       then CFG=.claude
else echo "no claude-config/ or .claude/ found — run from the repo root"; exit 2; fi

fail=0
pass(){ echo "  PASS  $1"; }
bad(){  echo "  FAIL  $1"; fail=1; }
warn(){ echo "  WARN  $1"; }

AGENTS=$(ls "$CFG"/agents/*.md   2>/dev/null | wc -l | tr -d ' ')
CMDS=$(ls   "$CFG"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Forge lint — config: $CFG ($AGENTS agents, $CMDS commands)"

# 1. No stale agent/command counts in the docs.
badc=0
while read -r n; do [ -n "$n" ] && [ "$n" != "$AGENTS" ] && badc=1; done \
  < <(grep -rhoiE '[0-9]+ agents'   "$CFG" 2>/dev/null | grep -oE '^[0-9]+')
while read -r n; do [ -n "$n" ] && [ "$n" != "$CMDS" ]   && badc=1; done \
  < <(grep -rhoiE '[0-9]+ commands' "$CFG" 2>/dev/null | grep -oE '^[0-9]+')
[ "$badc" = 0 ] && pass "doc agent/command counts match actual ($AGENTS/$CMDS)" \
                || bad  "a doc states an agent/command count != actual ($AGENTS/$CMDS)"

# 2. No dead path-variable notation in agents/commands (Wall 3 is a convention).
if grep -rqE '\$VENTURE|\$STATE|\$WORKTREE|\$VDIR|\$LEDGER|\$LEARNINGS|\$DELIVERABLES' \
     "$CFG"/agents "$CFG"/commands 2>/dev/null; then
  bad "dead path-variable notation (\$VENTURE/etc) in agents/commands — use literal ventures/<slug>/"
else pass "no dead path-variable notation in agents/commands"; fi

# 3. The machinery log does not live in learnings.md.
if grep -rqi '## System fixes' "$CFG"/memory/learnings.md 2>/dev/null; then
  bad "'## System fixes' in learnings.md — machinery changes belong in CHANGELOG.md"
else pass "learnings.md holds no machinery log"; fi

# 4. Safety walls intact in settings.json.
S="$CFG/settings.json"
if grep -q '"Bash(git push:\*)"' "$S" && grep -q '"Bash(git merge:\*)"' "$S" \
   && grep -q '"Bash(\*deploy\*)"' "$S" && grep -q 'Edit(.claude/settings.json)' "$S"; then
  pass "settings.json walls intact (push/merge/deploy denied; settings-edit gated)"
else bad "settings.json is missing a wall (push/merge/deploy) or the settings-edit gate"; fi

# 5. Every reference cited in SKILL.md exists on disk.
SKILL=$(find "$CFG"/skills -name SKILL.md 2>/dev/null | head -1)
miss=0
for ref in $(grep -oE 'references/[a-z0-9-]+\.md' "$SKILL" 2>/dev/null | sort -u); do
  [ -f "$(dirname "$SKILL")/$ref" ] || { warn "SKILL.md cites missing $ref"; miss=1; }
done
[ "$miss" = 0 ] && pass "every reference cited in SKILL.md exists" \
               || bad  "SKILL.md cites a missing reference (see WARN)"

# 6. Every command (except /start) has an eval suite.
emiss=0
for c in "$CFG"/commands/*.md; do
  b=$(basename "$c" .md); [ "$b" = start ] && continue
  [ -f "$CFG/evals/$b.md" ] || { warn "no eval suite for /$b"; emiss=1; }
done
[ "$emiss" = 0 ] && pass "every command (except /start) has an eval suite" \
                 || bad  "some commands lack an eval suite (see WARN)"

# 7. The eval baseline is established (no _unrun_).
if grep -q '_unrun_' "$CFG"/evals/BASELINE.md 2>/dev/null; then
  bad "BASELINE.md still has _unrun_ capabilities — the eval gate isn't established"
else pass "BASELINE.md has no _unrun_ capabilities"; fi

echo ""
[ "$fail" = 0 ] && echo "forge-lint: OK" || echo "forge-lint: FAILURES above (exit 1)"
exit $fail
