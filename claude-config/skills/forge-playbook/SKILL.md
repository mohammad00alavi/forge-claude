---
name: forge-playbook
description: >
  Master orchestration playbook for building products zero-to-sell, with
  effort scaled to difficulty and a learning loop that compounds across
  ventures. Use whenever the user wants to start a new venture/product/MVP/app/
  SaaS, assess what a project would take, or run any stage of the
  build-to-market lifecycle. Triggers on "build me a", "I have an idea for",
  "let's make a product", "how hard would X be", "take this to launch", or any
  /assess, /brainstorm, /architect, /forge, /gtm, or /improve command.
---

# Forge Playbook (v2)

Take an idea from zero to sellable, spending exactly as much effort as the
project's difficulty justifies — and get *better at estimating that* every time
you ship. This is Venture Forge's difficulty-routing and business lifecycle,
hardened with Professor's five load-bearing walls and a compounding learning
loop.

## The core loop

Forge has TWO modes. BUILD a new product zero-to-sell, then MAINTAIN it.

**BUILD MODE** (greenfield — a product that doesn't exist yet):
```
/start    -> first-run orientation (60s) -> walks you into your first /assess
/assess   -> READ learnings -> score difficulty (T0-T4) -> propose roster +
            model/effort + cost band -> STOP for tier approval
/brainstorm (if fuzzy) -> sharpen into value prop + scope
/architect -> READ learnings -> tech + business architecture -> finalize roster
/forge    -> build (eng loop) + business track, both gated objectively
/gtm      -> marketing + sales deliverables, scaled to tier
ship      -> launch checklist + WRITE learnings back
```

**MAINTAIN MODE** (an EXISTING codebase — fix/improve a running product):
```
/maintain -> set up an existing project for maintenance (explore, state,
            deny-list sensitive paths, optional triggers for always-running)
/fix      -> live-fix loop: explorer maps code -> fixer diagnoses + smallest
            diff -> verifier checks -> STOP for approval. Manual or triggered.
/improve-arch -> INTERACTIVE architecture session: find deepening opportunities
            (shallow->deep modules), grill the chosen one, execute gated. Distinct
            from /fix (bug-fixing); sit-with-it, not a background loop.
```

**META:**
```
/research -> deep multi-perspective research on any topic (STORM method:
            5 perspectives + contradiction map + synthesis + self-critique,
            grounded in real web search). Standalone, or invoked by the
            strategist/architect when a venture needs real understanding.
/grill    -> stress-test a plan/design before building: relentless one-question-
            at-a-time interview surfacing hidden assumptions. Used by strategist
            (fuzzy ventures) + architect (long-lived decisions).
/improve  -> fix the system's own agent/command files when machinery misbehaves
```

Choosing the mode: if the thing doesn't exist yet → BUILD. If it exists and you
want to fix/change it → MAINTAIN. Build mode's explorer-less pipeline is wrong
for existing code; maintain mode's "smallest diff" is wrong for greenfield.
Maintain mode is documented in references/maintenance-mode.md — including how
"always-running" works (wide autonomy, NARROW permissions) and the deny-list
pattern for money/safety code.

Per-venture memory: `ventures/<slug>/`. Cross-venture memory:
`.claude/memory/learnings.md`. Read `references/lifecycle.md` for the full
stage protocol.

## STEP 0 - Consult the learning loop (NEW, do this first)

Before scoring anything, read `.claude/memory/learnings.md`. Past ventures have
recorded where estimates missed, what build traps recurred, and what routing
worked. Your estimate must be calibrated by those, not just the static rubric.
Full discipline: `references/learning-loop.md`.

## STEP 1 - Difficulty assessment

Score the idea on five axes (0-3 each, total 0-15), adjusted by what the
learnings ledger says. Full rubric: `references/difficulty-rubric.md`.

| Tier | Score | What | Examples |
|------|-------|------|----------|
| T0 Micro | 0-2 | Static/single-purpose, no backend | Landing page, waitlist |
| T1 Small | 3-5 | One feature, simple data, maybe auth | Marketing site + form, CRUD tool |
| T2 Standard | 6-9 | Multi-feature app, real backend, payments | SaaS MVP, marketplace v1 |
| T3 Large | 10-12 | Multi-domain, integrations, scale | B2B platform, multi-tenant SaaS |
| T4 Complex | 13-15 | Novel/regulated/multi-system | Fintech, healthtech |

Five axes: scope, technical novelty, data/state, integration surface,
risk/compliance.

## STEP 2 - Route effort to the tier

The tier picks roster, models, and effort. `/assess` proposes; the human
approves the tier before spend. Rationale + 70/20/10 cost pattern:
`references/routing.md`.

| Tier | Agents | Orchestrator | Workers | Graders | Business |
|------|--------|--------------|---------|---------|----------|
| T0 | architect(light) + 1 builder | Sonnet/med | Sonnet/low | - | landing copy |
| T1 | + reviewer | Sonnet/high | Sonnet/med | Haiku/low | + basic GTM doc |
| T2 | full eng loop + pm + marketer | Opus/high | Sonnet/med | Haiku/low | strategy + assets |
| T3 | + devops + ui-ux + sales | Opus/high | Sonnet/high | Haiku/med | full GTM |
| T4 | + compliance + 2nd verifier | Opus/xhigh | Opus/med | Sonnet/med | + compliance |

Effort ladder (`effort:` frontmatter): low -> medium -> high -> xhigh. Default
high; drop for mechanical work; xhigh only for T4 ambiguity. Never run T0 on
Opus.

## STEP 3 - Roster is emergent

The table is the *starting* roster; the architect finalizes it from what the
project actually is. More agents != better - review bandwidth is the ceiling,
and each agent must earn its tokens with a distinct, checkable output.
Roster details: `references/agent-roster.md`.

## The five load-bearing walls (always enforced)

These are non-negotiable. Full text: `references/five-walls.md`.

1. The git-gate is the safety spine (mechanical, even with Bash(*) on): local
   git (add/commit/gh pr create) is free; `git push`/merge/force/deploy are
   DENIED. TWO mechanisms enforce it: the settings deny list AND a PreToolUse
   hook (.claude/hooks/block-dangerous-git.sh) that greps the ACTUAL command —
   so a chained `cd foo && git push` that could slip past a deny-glob is still
   blocked (exit 2). Agents physically cannot push; only the human pushes after
   local review. Mechanical wall, not Professor's prose — stronger, costs
   nothing. (Hook adapted from mattpocock's git-guardrails.)
2. The gate gates the merge - objective (typecheck/lint/test/build) before and
   after; opinions and "looks done" do not count.
3. Path variables, never hardcoded paths - `$VENTURE`, `$VDIR`, `$STATE`,
   `$WORKTREE`, `$LEDGER`, `$LEARNINGS`.
4. Worktree isolation for parallel builders - no file collisions.
5. Self-improvement at the source - fix bad agent/command files via `/improve`,
   gated by a prompt-quality check.

## Gates are rubric-based (NEW framing)

Both code and business outputs are graded against an explicit rubric by a
separate grader in its own context (the maker never grades itself). This is
Anthropic's "outcomes" pattern: state what "good" looks like, grade against it.
- Code: `references/verification.md` (the objective gates + the spec).
- Business: `references/business-quality.md`.
- OPTIONAL: `references/cross-verify.md` — route the final code review through a
  DIFFERENT provider's model (Codex/Gemini) so it catches blind spots a Claude
  verifier shares with the builder. Opt-in per venture via STATE.md
  `Cross-verify`. Defeats representational collapse.

## Hard rules (never relax)

1. Difficulty assessed before building; tier approved before spend.
2. The maker never grades its own work.
3. The five walls above.
4. Forbidden to agents (denied/gated): pushing to remote, merges, deploys,
   spending money, publishing public content — these are DENIED (push/merge/
   deploy) or human-only. Dependency installs (`npm install`, lockfile edits)
   flow freely by default for a smooth run — BUT for client work, move
   `Bash(npm install:*)` back to the settings `ask` list (a dependency added to
   a client codebase is a supply-chain decision someone may need to account
   for). The one thing always gated: editing `.claude/settings.json` itself —
   the agent must ask before changing its own permissions, so the push wall
   can't be silently removed.
5. Scale down readily - over-engineering is the most common failure.
6. Read learnings before estimating; write learnings at every feature boundary
   AND after shipping (Hermes cadence) — declarative facts, not imperatives;
   nothing stale in a week.
7. If the machinery itself is found wrong mid-work (a bad agent instruction, a
   misrouting command), proactively flag it and propose `/improve` — don't
   silently work around it. Unmaintained machinery is a liability.
8. Bash discipline (now good-practice, not prompt-avoidance): with `Bash(*)`
   allowed, operator chains no longer prompt — but separate simple commands are
   still clearer for diagnostics (a `||` no longer hides which check failed).
   Prefer them where natural; not enforced. See references/bash-discipline.md.
9. Project scope (now mechanically enforced): home-directory reads (`~/.nvm`,
   `~/.ssh`, `~/.config`, `~/.aws`, etc.) are DENIED in settings — agents
   physically cannot read them, so no prompts. Still prefer in-project files
   (`.nvmrc`, `package.json`) for env detection — it's cleaner and the deny
   makes home-dir probing fail anyway. See references/project-scope.md.
10. Stack-agnostic - architect picks per project.

## References

- `learning-loop.md` - the compounding-memory discipline (NEW).
- `five-walls.md` - the non-negotiable structural guarantees (NEW).
- `difficulty-rubric.md` - five-axis 0-15 scoring.
- `routing.md` - model/effort/agent routing + cost pattern.
- `agent-roster.md` - every agent, trigger, tier.
- `lifecycle.md` - stage-by-stage protocol.
- `business-quality.md` - rubric for business deliverables.
- `verification.md` - code gate rubric.
- `cross-verify.md` - OPTIONAL cross-provider verification (different model
  family reviews Claude's code; defeats representational collapse). Opt-in.
- `eval-harness.md` - golden tests for Forge's OWN machinery; run before/after
  every /improve so a bad self-edit gets caught (.claude/evals/).
- `cost-tracking.md` - Effective Tokens metric + cost-per-accepted-change, so
  spend is measurable and routing is verifiable (lean, no gateway).
- `models.md` - alias→pinned-version map; upgrade ritual so a silent model swap
  can't regress the machinery undetected.
- `maintenance-mode.md` - MAINTAIN MODE: always-running done safely (wide
  autonomy + narrow permissions), triggers, deny-list for money/safety code.
- `bash-discipline.md` - keep routine commands simple (separate, not operator-
  chained) so runs don't stall on the operator-approval guard; operators kept
  where they do real work.
- `project-scope.md` - stay inside the project for environment detection (read
  .nvmrc/package.json or ask); never probe `~/.nvm`/home dotfiles, which trips
  the out-of-project guard.
- `diagnosis-discipline.md` - (maintain mode) build a red-capable feedback loop
  BEFORE hypothesizing about a bug; the fixer's core method. From mattpocock.
- `tdd-discipline.md` - vertical-slice TDD (one test→one impl), behavior-not-
  implementation tests that survive refactors. From mattpocock.
- `storm-research.md` - multi-perspective research (5 voices → contradiction map
  → synthesis → self-critique), grounded in real web_search. Used by `/research`
  and invoked by strategist/architect for novel ventures. From Stanford STORM.
- `grilling.md` - stress-test a plan one question at a time before building.
  Used by `/grill`, strategist, architect. From mattpocock.
- `codebase-design.md` - deep-module vocabulary (interface/seam/depth/leverage/
  locality) + deletion test. Sharpens the architect. From mattpocock.
- `architecture-improvement.md` - (maintain mode) find + execute deepening
  opportunities, interactive. Used by `/improve-arch`. From mattpocock.
- `state.md` - per-venture state file format.
