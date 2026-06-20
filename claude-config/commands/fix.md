---
description: MAINTAIN MODE. Live-fix a bug or make a small change on an existing codebase — explore, diagnose, fix, gate, stop for approval — $ARGUMENTS
---

Fix / change on the existing project: $ARGUMENTS

This is maintain mode (not build mode — the project already exists). Borrows
Professor's /jc shape: works on the real codebase, any bug or small change, full
gates, then a local commit + PR (you review and push). For zero-to-sell of a NEW product, use
/assess + /forge instead.

Flow:
1. **Explore** — spawn `explorer` to map the relevant code: where it lives,
   current behavior, nearest test, pattern to copy, blast radius, and any
   forbidden-path flags. Read STATE.md "Dead ends" first.
2. **Fix** — spawn `fixer`: diagnose root cause → failing test first → smallest
   correct diff matching existing patterns → run full gates (typecheck/lint/
   test/build). Max 3 fix rounds; if cross-verify is on and still red, try a
   cross-model rescue before escalating to me.
3. **Verify** — spawn `verifier` (independent, cross-provider too if STATE.md
   Cross-verify is set): checks the diff against the diagnosis + gates. A FAIL
   from either verifier blocks.
4. **Commit locally + stop at push** — commit the fix locally and open a PR
   (`git add`/`commit`/`gh pr create` are free). Show me the diagnosis, the
   diff, and the gate results. Do NOT push — I review the local commits/PR and
   push by hand. That's the gate.

Hard rules: local git free (commit, gh pr create); `git push`/merge/deploy
DENIED — only the human pushes, after local review (even if this ran from a
trigger). NEVER touch the project's denied paths — flag and stop. Record any
dead end in STATE.md with WHY.
