---
description: Fix the system's own agent/command/skill files when the machinery misbehaves (wall 5, lean /pcm) — $ARGUMENTS
---

Improve the Forge system itself: $ARGUMENTS

This is wall 5 — self-improvement at the source. Use it when an AGENT or COMMAND
behaved wrong (bad routing, a weak instruction, a missing guardrail), NOT for
domain lessons about a venture (those go to the learning loop / learnings.md).

**Maintenance norm (from Hermes Agent): patch immediately, don't wait to be
asked.** If during normal work the system notices one of its own
agent/command/skill files is outdated, missing a step, or has a wrong
instruction, it should surface that and propose the `/improve` fix right then —
not silently work around it. Unmaintained machinery becomes a liability. (The
human still approves the framework edit — see step 5 — but the system should
PROACTIVELY flag the need, the way it proactively writes learnings.)

Process:

1. **Diagnose** — identify the exact file and the instruction that caused the
   bad behavior. Quote it. Name the failure class it should prevent going
   forward (not just this one instance).
2. **Prompt-quality gate** — before editing any `.claude/agents/*.md`,
   `.claude/commands/*.md`, or `SKILL.md`, check the edit against these rules:
   - Does it pass the "cut test" (every line earns its place; no filler)?
   - Is it specific and unambiguous (tells the agent what to do / not do, with
     a concrete trigger)?
   - Does it preserve the file's existing structure and voice?
   - Does it avoid weakening any safety/ethics/git/gate rule? (Those are
     sacred — never weaken them to make something pass.)
3. **Eval BEFORE** — run the affected capability's golden suite in
   `.claude/evals/<capability>.md` (3× each, median) and note the score vs
   `.claude/evals/BASELINE.md`. This confirms the starting point.
4. **Edit at the source** — make the smallest change to the actual agent/command
   file that prevents the failure class. Surgery, not a wiki note.
5. **Eval AFTER** — re-run the same suite. If the score dropped 2+ cases below
   baseline, the edit DEGRADED the machinery — revert or fix, do not ship it.
   This before/after gate is what makes self-improvement safe (it's the exact
   check that would have caught Claude Code's own March 2026 prompt regression).
   See references/eval-harness.md.
6. **Record** — append a one-line dated entry to the repo `CHANGELOG.md`: what
   was wrong, what changed. NOT learnings.md — that file holds durable
   cross-venture domain facts only.
7. **Note the reload caveat** — agent/command registries load at session start;
   tell me the change lands at the next session (or next spawn), not mid-run.

When this command runs shell or detects the environment, it follows the same
disciplines as every agent: references/bash-discipline.md (routine checks as
separate simple commands, not `&&`/`||`/`;` chains) and references/project-scope.md
(read in-project `.nvmrc`/`package.json`; never probe `~/.nvm` or home dotfiles).

Show me the diff before applying. This command edits the framework, so I
approve framework edits the same way I approve code commits.
