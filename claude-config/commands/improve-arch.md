---
description: MAINTAIN MODE. Find architectural deepening opportunities in an existing codebase, then grill + execute the chosen one (interactive, not background) — $ARGUMENTS
---

Improve the architecture of the existing project: $ARGUMENTS

Interactive architecture session (references/architecture-improvement.md) —
distinct from /fix (bug-fixing). NOT a background loop; it's a sit-with-it tool.
Uses the deep-module vocabulary (references/codebase-design.md) and the grilling
loop (references/grilling.md).

Flow:
1. **Explore** — read STATE.md (incl. "Dead ends"), then the `explorer` walks the
   code noting friction: shallow modules (interface ≈ implementation), poor
   locality, leaked seams, hard-to-test interfaces. Apply the deletion test.
2. **Present candidates** — deepening opportunities, each with files / problem /
   solution / benefits (in leverage + locality terms) / before-after / strength
   (Strong / Worth exploring / Speculative). End with a top recommendation, then
   ask which to explore. Optional HTML report to a TEMP dir (never the repo).
3. **Grill the chosen one** — walk the design tree one question at a time (each
   with your recommended answer): constraints, the deepened module's shape, what's
   behind the seam, which tests survive.
4. **Execute, gated** — the `fixer`/`builder` makes the smallest correct diff
   (TDD: test through the public interface), the `verifier` gates it, commit
   locally + PR; the human pushes. A refactor is a normal gated change.

Record decisions in Forge's state (STATE.md / Dead ends / learnings.md), NOT a
separate ADR/CONTEXT.md system. Don't let a deepening balloon into a rewrite —
each candidate is a bounded, gated change.
