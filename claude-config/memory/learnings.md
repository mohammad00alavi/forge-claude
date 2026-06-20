# Forge learnings (read before every /assess and /architect)

> The system's compounding memory. Append distilled rules here after each
> venture. Read it back to calibrate the next estimate. Confidence markers:
> ↑ proven once, ↑↑ proven 3+ times (promote to rubric), ↓ misfired
> (down-weight or remove). Keep a human in the loop — prune confidently-wrong
> rules. Format and discipline: skills/forge-playbook/references/learning-loop.md

## Estimation calibration
_(empty — fills as you ship ventures and discover where estimates missed)_

## Build patterns that worked
_(empty)_

## Build traps to avoid
_(empty)_

## Deliverable lessons
_(empty)_

## Routing / cost lessons
_(empty)_

## System fixes (machinery bugs fixed via /improve, dated)
- [2026-06-18] Added a 3-skill cluster from mattpocock (Option A): (1) grilling
  — stress-test a plan one-question-at-a-time before building, wired into
  strategist (fuzzy ventures) + architect (long-lived decisions), via `/grill`;
  (2) codebase-design — deep-module vocabulary (interface/seam/depth/leverage/
  locality) for the architect; (3) improve-codebase-architecture — a new
  INTERACTIVE maintain-mode capability (`/improve-arch`) to find + execute
  deepening opportunities, distinct from /fix. KEY ADAPTATION: all three record
  decisions in Forge's existing state (STATE.md / Dead ends / learnings.md), NOT
  Matt's parallel CONTEXT.md/ADR system — one memory system, no drift. Skipped
  domain-modeling + grill-with-docs for now (they introduce the ADR layer, a
  bigger architectural merge).
- [2026-06-18] Added STORM research method (Stanford, NAACL 2024) as a skill +
  `/research` command, wired into strategist (novel-venture assessment) and
  architect (unfamiliar technical decisions). 4 stages: multi-perspective scan →
  contradiction map → synthesis → self-critique. GROUNDED IN REAL web_search
  (the upgrade over the paste-only version — claims must cite sources). Fixes a
  real gap: strategist/architect previously researched from a single angle. The
  self-critique stage reuses Forge's maker-doesn't-grade-itself principle. Note:
  the "25% more organized" claim is from Stanford's full retrieval system, not
  the prompt version — so we ground ours in actual web search to earn it.
- [2026-06-18] Hardened the push wall + upgraded bug-fixing, borrowing 3 skills
  from mattpocock's collection: (1) git-guardrails PreToolUse hook — greps the
  actual command so a chained `cd x && git push` can't slip past the deny-glob
  (closed a real gap that Bash(*) opened); (2) diagnosing-bugs feedback-loop
  discipline into the fixer (build a red-capable loop BEFORE theorizing);
  (3) TDD vertical-slice rule into builder+fixer (one test→one impl, behavior
  not implementation). Skipped Matt's issue-tracker + writing skills as
  out-of-scope.
- [2026-06-18] Behavioral fixes (bash-discipline, project-scope) reduced but did
  not eliminate the operator + home-directory prompts — agents kept re-deciding
  to probe `~/.nvm`. Switched to the mechanical model: added `Bash(*)` (ends
  operator prompts, Professor's approach) + broad home-directory DENY (ends the
  ~/.nvm prompts — deny overrides Bash(*)). KEPT git push/merge on mechanical
  deny rather than moving to Professor's prose gate — stronger, costs nothing,
  and the prompts being fixed were never about push. Lesson: prose/behavioral
  rules have a probabilistic floor; for a guarantee, use a mechanism (deny).
- [2026-06-18] Agents probed the home directory (e.g. `~/.nvm/alias/default`)
  for environment detection, tripping Claude Code's out-of-project read guard
  and stalling runs. Fix: added project-scope rule (SKILL rule 9 + references/
  project-scope.md + reminders in builder/fixer/verifier/devops) — detect env
  from in-project files (.nvmrc, package.json) or ask the user; never probe the
  home directory. Same root cause as the operator-chain fix: over-eager
  environment detection.
- [2026-06-17] Agents wrote operator-chained bash (`&&`/`||`/`;`) for routine
  env/version checks, tripping Claude Code's operator-approval prompt and
  stalling runs. Fix: added bash-discipline rule (SKILL rule 8 + references/
  bash-discipline.md + reminders in builder/fixer/verifier) — routine checks run
  as separate simple commands that match the allow list; operators kept only
  where they do real work. No capability lost.
