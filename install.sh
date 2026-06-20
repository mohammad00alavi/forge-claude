#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$PWD}"
if [ "$TARGET" = "$HERE" ]; then echo "Run against a workspace dir, not this folder. Usage: ./install.sh /path/to/workspace"; exit 1; fi
mkdir -p "$TARGET/.claude"
cp -rv "$HERE/claude-config/." "$TARGET/.claude/" 2>/dev/null || cp -rv "$HERE/.claude/." "$TARGET/.claude/"
[ -d "$TARGET/ventures" ] || cp -rv "$HERE/ventures" "$TARGET/ventures" 2>/dev/null || true
# Ensure the git-guardrail hook is executable (zip may not preserve the bit)
if [ -f "$TARGET/.claude/hooks/block-dangerous-git.sh" ]; then
  chmod +x "$TARGET/.claude/hooks/block-dangerous-git.sh"
  echo "  (made git-guardrail hook executable)"
fi
echo ""
echo "Forge v3.8 installed into: $TARGET"
echo "  13 agents, 12 commands, forge-playbook skill, learning loop,"
echo "  git-guardrail hook (hardens the push wall), gated settings."
echo ""
echo "Start:  cd $TARGET && claude  ->  /start  (or /assess \"your idea\")"
echo "Note: the hook needs the path \$CLAUDE_PROJECT_DIR — Claude Code sets this"
echo "      automatically. If hooks don't fire, check 'claude --version' is current."
echo "Remember: git add .claude/memory/learnings.md ventures/  (so memory compounds)"
