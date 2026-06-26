# Forge — Changelog

Machinery changes to Forge itself (agents, commands, skill, hooks, settings,
evals). This is where self-improvement / `/improve` history lives — **not** in
`.claude/memory/learnings.md`, which is reserved for durable cross-venture
*domain* facts (per the learning-loop discipline).

## Version history

Forge iterated rapidly over 2026-06-17 → 06-18, versioned as dist snapshots.
Current: **v3.9**.

| Version | Date | Highlights |
|---|---|---|
| v2.1–v2.3 | 2026-06-17 | five walls, difficulty engine, business lifecycle |
| v3.2–v3.3 | 2026-06-17/18 | routing + roster refinements |
| v3.6 | 2026-06-18 09:57 | a mid-cycle install snapshot |
| v3.8 | 2026-06-18 22:22 | adds `/grill`, `/research` (STORM), `/improve-arch` |
| v3.9 | 2026-06-25 | current; eval coverage 12/12, maturity + P2 hardening, self-maintenance, research→build bridge, first git-tagged minor |

> Versions were historically cut as zip snapshots, not git tags. Going forward,
> tag releases in git so version provenance is unambiguous.

## Machinery fixes (moved here from learnings.md "System fixes")

- [2026-06-26] Verifier: green objective gates (typecheck/lint/build/axe) don't
  prove styling RENDERS — a valid-syntax colour token / SVG fill can pass every
  gate yet paint nothing. Added a rule to verifier.md + a checklist item to
  verification.md: visual/styling criteria are reported UNVERIFIED unless a test
  observes the rendered result. Surfaced by a real venture's frontend `/improve`,
  ported to source; verifier suite held 6/6 (3×), no regression.

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

## 2026-06-24 — Maturity pass (post-evaluation)

Applied after a full maturity audit:

- **Established the first eval BASELINE** (was `_unrun_`): /assess 6/6, verifier
  6/6, /improve 8/8 (3× median); /fix 6/6, /research 5/5 (1×). The /improve
  safety gate now has numbers to compare against. Provisional — re-run in the
  live runtime to make authoritative.
- **Reframed Wall 3 honestly.** Dropped the never-wired `$VENTURE/$STATE`
  path-variable claim (0 files ever used it; 10 hardcoded `ventures/<slug>`);
  documented the fixed `ventures/<slug>/…` convention instead (five-walls.md,
  SKILL.md, README).
- **Fixed stale/contradictory docs.** Agent/command counts 11→13 / 6→12
  (start.md); evals index 3→5 suites (evals/README); Wall 1 git wording
  corrected to the real model (local commit free; push/merge/deploy denied;
  builder + fixer own git); T0 caveat added to "the maker never grades its own
  work" (SKILL.md); dropped the stale "(v2)" label on the playbook title.
- **Cross-verify degrades gracefully.** If the codex/gemini plugin or rescue
  command isn't installed, fall back to the Haiku verifier / escalate to the
  human rather than hard-failing (cross-verify.md, forge.md); corrected the
  past Gemini retirement date.
- **Cleaned the learning loop.** Moved this machinery log out of learnings.md
  into this CHANGELOG; reset the distributable learnings.md to a clean template;
  seeded the working install's loop with real declarative facts distilled from
  several real ventures already run.

Recorded next targets for the now-functional gate (see `evals/BASELINE.md` →
"Known fragilities"): assess gate-non-waivable, assess multi-user data anchor,
verifier forbidden-path verdict (FAIL vs ESCALATE), and wiring bash-discipline /
project-scope references into `/improve`.

## 2026-06-24 — Instruction-gap pass (eval-driven)

Used the now-functional gate on the six fragilities baselining surfaced. Each:
eval-before (fragile, 2-of-3) → smallest surgical edit → eval-after (solid, 3/3)
→ no regression. Case-level suite scores unchanged (assess 6/6, verifier 6/6,
improve 8/8), but the previously-fragile cases are now solid.

- **/assess A1** — the tier-approval gate is now non-waivable in BOTH the command
  and the strategist (assess.md, strategist.md): "skip the gate / I pre-approve
  everything" no longer authorizes starting.
- **/assess E1** — difficulty-rubric.md Axis 3 now anchors multi-user /
  shared-write / permissions at data axis ≥ 2 (a shared to-do list is not a T0).
- **/assess H3** — routing.md and SKILL.md tier tables now roster compliance at
  T3 for a regulated domain, not only T4 (removes the table-vs-rule contradiction).
- **verifier A1** — verifier.md + verification.md: a touched forbidden path
  (auth/payments/billing) is ALWAYS ESCALATE — never a FAIL defect, never a
  silent PASS.
- **verifier H2** — a PASS must enumerate each acceptance criterion and how it
  was confirmed (was soft discipline; now explicit in both files).
- **/improve BD/PS** — commands/improve.md now references bash-discipline.md and
  project-scope.md, so those disciplines are command-enforced, not incidental.
- Fixed a contradiction introduced earlier: `/improve` step 6 now logs machinery
  changes to this CHANGELOG (not learnings.md "## System fixes").

## 2026-06-24 — P2 hardening pass

The deferred P2 backlog items. None changes a graded capability's decision logic
(assess/verifier/improve/fix/research), so the eval baseline still holds — no
re-baseline needed (the lean STATE keeps the "Dead ends" field /fix reads).

- **Model-routing instrumentation (measured, not estimated).** New PreToolUse
  hook `hooks/log-agent-spawn.sh` logs every agent spawn + model tier to
  `ventures/<slug>/routing-ledger.tsv`; registered additively in settings.json
  (no deny rule touched). Read the mix: `cut -f3 routing-ledger.tsv | sort | uniq -c`.
  Tested — correct agent→model map, never blocks, jq + sed fallback both work.
- **CI gate template.** `claude-config/templates/ci/forge-gates.yml` (typecheck/
  lint/test/build, mirrors the verifier) so gates run on every PR, not just
  locally; devops PREPARES it, the human installs it (agents can't write
  `.github/workflows/`). YAML validated.
- **Lean T0/T1 STATE variant.** Added to references/state.md + wired into
  lifecycle Stage 0 — a minimal state file for low tiers (over-engineering is
  Forge's #1 failure mode). Keeps Dead ends / Escalated so /fix is unaffected.
- **Worktree flow exercised.** builder.md step 2 now carries the concrete,
  validated commands; the full add → build → list → remove flow was run in a
  scratch repo and works (Wall 4 was designed but never exercised before).
- **Git-tag release hygiene.** Added RELEASING.md (tag-based process) and created
  a local lightweight tag `v3.8` at the released commit. The 2026-06-24 work is
  the v3.9 candidate.
- install.sh now chmods all hook scripts (not just the git guard).

## 2026-06-25 — Eval coverage pass

Closed the eval-coverage gap (was 5 of 12 commands gated) and deduped the
routing map.

- **7 new golden suites** — architect (4 cases), forge (6), gtm (5), grill (4),
  maintain (5), brainstorm (4), improve-arch (6) = 34 cases, each happy/edge/
  adversarial with an objective PASS-IF. Provisionally baselined (1×): all 34
  pass. Coverage is now **12/12 commands** (`/start` excluded). evals/README and
  BASELINE.md updated; 65 cases total.
- **Roster→model dedup** — the routing-ledger hook now reads each agent's model
  from its OWN frontmatter (`.claude/agents/<agent>.md`) instead of a hardcoded
  case map, so there's a single source of truth. routing.md notes the frontmatter
  is authoritative. Re-tested: correct mapping, unknown agents → `unknown`.
- QA of the new suites surfaced fixes, applied: reconciled a real contradiction
  in marketer.md (frontmatter "Engaged at T2+" vs body "All tiers: positioning");
  tightened grill H1 (PASS-IF was weaker than its EXPECT) and maintain H2 (had
  tested deny globs already in the defaults); fixed an architect EXPECT that
  named devops as a T2 default. Remaining minor case-quality notes are tracked in
  BASELINE.md.

No graded capability's decision logic changed, so the prior baselines still hold.

## 2026-06-25 — Research→build bridge, version history, eval tightening

Addressed the last config-fixable audit items.

- **Research→build bridge.** /research now ends venture/market research with a
  distilled venture brief written to `ventures/<slug>/research-brief.md` + an
  explicit next step (`/assess "<one-liner>"`, or "validate first"), so research
  hands off instead of stalling. (The cross-repo human-carry part remains a
  workflow choice, not config.)
- **Version history in git.** Added `VERSION-HISTORY.md` (dated v2.1→v3.8 lineage)
  and `scripts/import-version-history.sh`, which reconstructs the zip-era snapshots
  as a tagged `version-history` branch WITHOUT touching main — tested in a scratch
  repo (correct commits/tags, main untouched, returns to the original branch).
  Documented in RELEASING.md.
- **Eval-case tightening** (the BASELINE "known notes"): gtm +2 (positioning
  quality, T2 boundary) → 7; grill +1 (decisions recorded to STATE.md) → 5;
  brainstorm +1 (brief persisted) → 5; improve-arch H1 now requires a SPECIFIC
  shallowness diagnosis; maintain E2 now requires an explicit `Gates: MISSING`
  marker. Re-baselined: all pass — and maintain E2 (correctly) caught a real gap
  (no gates field in the STATE template), which was then fixed (added `Gates:` to
  both STATE templates + a maintain.md clause). Suite total: **69 cases / 12 suites.**

The eval gate doing its job: a tightened case surfaced a machinery gap, the gap
was fixed, and the case now passes legitimately.

## 2026-06-25 — Self-maintenance (daily, maintainer-only)

A self-maintenance system for the Forge repo itself — observe daily, act on
confirmed patterns, ship on human approval. Everything lives in `maintenance/`
(OUTSIDE claude-config, so install.sh never ships it to user installs; users keep
`/improve` for fixing their own copy).

- **`maintenance/forge-lint.sh`** — a deterministic consistency gate that catches
  the audit-class regressions (stale counts, dead path-vars, machinery-log in
  learnings, a weakened wall, dangling refs, ungated commands, an unrun baseline).
  Tested: passes the current repo and correctly FAILS on injected regressions.
- **`maintenance/self-review.md`** — the daily LLM self-review playbook (health →
  eval gate vs BASELINE → mine routing-ledger / learnings / STATE signal → gated
  `/improve` fixes → digest → PR). Never pushes/merges/tags; the human ships.
- **`maintenance/forge-self-review.workflow.yml`** — a GitHub Action (daily cron):
  a turnkey `health` job (lint, no secret) + an optional `self-review` job (LLM,
  needs ANTHROPIC_API_KEY, opens a PR). Copy to `.github/workflows/` to enable.
- Anti-thrash by design: acts only on patterns seen ≥2× / a `↑↑` learning / an
  eval regression, ≤2 edits per run, with a cool-down on recently-touched files.
