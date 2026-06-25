#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$PWD}"
if [ "$TARGET" = "$HERE" ]; then echo "Run against a workspace dir, not this folder. Usage: ./install.sh /path/to/workspace"; exit 1; fi
mkdir -p "$TARGET/.claude"
cp -rv "$HERE/claude-config/." "$TARGET/.claude/" 2>/dev/null || cp -rv "$HERE/.claude/." "$TARGET/.claude/"
[ -d "$TARGET/ventures" ] || cp -rv "$HERE/ventures" "$TARGET/ventures" 2>/dev/null || true
# Ensure hook scripts are executable (zip may not preserve the bit)
if [ -d "$TARGET/.claude/hooks" ] && compgen -G "$TARGET/.claude/hooks/*.sh" >/dev/null; then
  chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true
  echo "  (made hook scripts executable)"
fi
echo ""
echo "Forge v3.9 installed into: $TARGET"
echo "  13 agents, 12 commands, forge-playbook skill, learning loop,"
echo "  git-guardrail + routing-ledger hooks, gated settings."
echo ""
echo "Start:  cd $TARGET && claude  ->  /start  (or /assess \"your idea\")"
echo "Note: the hook needs the path \$CLAUDE_PROJECT_DIR — Claude Code sets this"
echo "      automatically. If hooks don't fire, check 'claude --version' is current."
echo "Remember: git add .claude/memory/learnings.md ventures/  (so memory compounds)"
