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

- [2026-08-01] Builder live-proof plausibility + verifier E4 (from a venture
  `/improve`, ported to source): the builder live-"proved" an SSE messaging
  canary with 6–10ms round-trips — that was the chat UI's optimistic local echo,
  not the pipe; the shipped detector would have stayed green with SSE broken
  (venture PR #56; Copilot caught it in review, no verifier ran). Fix: builder.md
  hard rule (live proof must be plausible for the mechanism; any shipped
  detector must be shown to go red when its target breaks) + verifier.md step-2
  pin (implausible evidence is a FAIL, not a proof) + new eval case verifier/E4.
  Full 3×-median re-run after the edit: verifier 7/7→8/8 (71 cases), /forge
  6/6 — no regression. E4 passed 3/3 pre-edit too (the machinery held when
  actually run; the sentence + case pin it).

- [2026-06-30] Settings hardening (two walls): (1) `forceLoginMethod: "claudeai"`
  — Forge authenticates via the Claude.ai subscription, so runs don't bill API
  credits. (2) Settings lockdown — `Edit` and `Write` of `.claude/settings.json`
  moved from `ask` to DENY, and the git-guard PreToolUse hook now also blocks
  raw-shell writes to it (`>` / `sed -i` / `tee` / `cp` / `mv` / `dd` / …),
  closing the `Bash(*)` gap so no agent can rewrite the walls; a human edits
  settings by hand. Tested: shell writes blocked, reads allowed, git walls intact.

- [2026-06-30] Verifier visual rigor, round 2 + eval isolation (from
  `/improve`): (a) axe only checks the DEFAULT/static render — for controls with
  selected/hover/active/focus styling the verifier now reasons about each state's
  contrast by hand (a selected control can fail WCAG AA yet pass axe-0);
  verifier.md + verification.md extended. (b) NEW eval case E3 locks in that
  failure mode (axe-green but sub-AA selected state) — BASELINE verifier 6→7,
  70 cases total; E3 is fragile-by-design (median 2/3, ui-ux backstops). (c)
  eval-harness.md gains an ISOLATION rule after a real leak (a verifier-eval run
  created synthetic `slug.ts` fixtures that got committed): run evals in a
  throwaway worktree or treat the input as hypothetical, and assert a clean tree
  after. Ported to source; verifier re-verified 7/7 at median, no regression.

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

## 2026-08-04 — /automerge toggle (Option A, opt-in agent merge)

Design record: `docs/design/automerge/`. One human-set switch, both modes work:
OFF (default) = agents stop at a ready PR, the human merges — unchanged Forge
behavior. ON = agents may squash-merge THEIR OWN PRs, only under the merge-step
contract: review threads resolved (bots incl.), CI green, behind-zero via
`gh pr update-branch`, fresh gate, no `human:*`/`automerge:halt`, no protected
paths, never `--admin`.

- **Repo (maintainer):** `maintenance/automerge.command.md`,
  `maintenance/forge-loop-merge-step.md` (the contract),
  `maintenance/automerge-merge-guard.sh` (PreToolUse wall: variable + fresh
  `forge-lint`, fail-closed).
- **Installs (shipped):** `claude-config/commands/automerge.md`,
  `claude-config/hooks/automerge-merge-guard.sh`, wired in
  `claude-config/settings.json`. Also closes a pre-existing gap: `gh pr merge`
  was walled by neither the deny list nor `block-dangerous-git.sh`; it is now
  fail-closed behind the toggle in every install.

## 2026-08-04 — Forge loop, forge-loop-ready (maintainer-only)

The repo's standing loop, lean edition: queue = GitHub issues labelled
`forge-loop-ready` (maintainer-applied — the injection guardrail); one iteration =
return path first (threads/CI/behind on open agent PRs), then one issue →
`agent/gh-<N>` worktree → maker (fixer/builder) → gate (`forge-lint` + affected
eval suite vs BASELINE) → fresh-context verifier → ready PR `Closes #N` →
toggle-aware merge step. Maker ≠ checker; the gate decides done.

- `maintenance/forge-loop.md` (playbook + one-time activation runbook),
  `maintenance/LOOP-STATE.md` (caps · escalate · roles · stop condition ·
  lessons), `maintenance/forge-loop.command.md` (optional `/forge-loop`).
- `maintenance/loop-push-guard.sh` — Wall 1's loop exception made mechanical:
  `git push` only as `git push [-u] origin agent/<branch>`; force/delete/tags/
  refspecs/non-origin all blocked (12-case behavior test in-repo).
- `docs/agents/{issue-tracker,triage-labels,domain}.md` — config trio for
  issue-shaping skills: GitHub tracker, `ready-for-agent`==`forge-loop-ready` bridge,
  domain-doc map.
- Deliberately NOT ported from the reference implementation: merge queue,
  scope/rate breakers, scheduled daemon workflows, verdict panel — volume
  machinery a one-maintainer repo doesn't need yet (see docs/design/automerge/
  option C for the record).

## 2026-08-04 — Consumer forge loop: the dev loop ships to every install

The loop is no longer maintainer-only — consumers get the full cycle in their
own projects: human labels issues `forge-loop-ready` → `/forge-loop` builds each
in an `agent/gh-<N>` worktree via a maker sub-agent → the PROJECT's own gate
(package.json scripts / STATE Gates / asked once, recorded) → fresh-context
verifier → ready PR `Closes #N` → toggle-aware merge step (`/automerge`) → next
issue. Agents may DRAFT issues (labelled `needs-triage`); only the human's
`forge-loop-ready` label queues work — the injection guardrail, unchanged.

- **Shipped:** `claude-config/commands/forge-loop.md` (the loop, repo resolved
  from the git remote, conventions + issue template embedded; per-project state
  in `.claude/loop/LOOP-STATE.md`), `claude-config/hooks/loop-push-guard.sh`,
  both wired in `claude-config/settings.json`. Evals: `forge-loop` suite
  (9 cases), BASELINE 14/14 commands, 89 cases.
- **PUSH WALL, v3.9.5 model:** the blanket push deny moved into the hooks so the
  loop can publish PR branches — `block-dangerous-git.sh` now blocks every push
  whose segments aren't exactly the sanctioned
  `git push [-u] origin agent/<branch>` shape, and `loop-push-guard.sh`
  validates it strictly (no force/delete/refspecs/tags/other remotes). 25-case
  behavior test green across both guards. Merge stays fail-closed behind
  `/automerge on`; force-push/merge/deploy stay denied in settings;
  `forge-lint` check 4 now asserts the new wall (force-push deny + all three
  guards wired) instead of the old blanket deny.
- **Review hardening (PR #7, Copilot):** both merge-guard editions now enforce
  the exact contract mode — `--squash --delete-branch` required, `--merge`/
  `--rebase` blocked, checked before the toggle so wrong modes fail even
  offline; the maintainer guard's fresh gate runs against the session's
  worktree (not the repo root) when merging from one; the push-scope regex
  forbids `:` so an `agent/<src>:<dst>` refspec can't retarget a protected
  ref. Guard behavior tests 25 → 42 cases, all green.
- **Review hardening, round 2 (PR #7, Copilot):** (a) all three push guards now
  block `git <global-flags> push` forms (`-c`/`-C`/`--git-dir`/…) that dodged
  the plain `git push` detection and could retarget the repo or config; the
  sanctioned shape is plain-only. (b) Both merge guards pin the merge to the
  repo whose toggle they honor — a `-R`/`--repo` naming any other repo is
  blocked (consumer edition resolves its repo from the remote and fails closed
  when it can't). Guard behavior tests 42 → 64 cases, all green.
- **Review hardening, round 3 (PR #7, Copilot):** all five guards now normalize
  the command before every check — backslashes and quotes stripped — so
  shell-quoting evasions (escaped whitespace, quote-splitting) can't dodge
  detection. `$VAR`/`eval` indirection is documented as beyond a string guard's
  reach; the ask-gate, branch protection, and human review back that residual.
  Guard behavior tests 64 → 77 cases, all green.
- **Review hardening, round 4 (PR #7, Copilot):** both merge guards now enforce
  the contract's own-PR scope mechanically — the merge must name an explicit PR
  number (bare/URL/branch targets blocked), and that PR's head ref must be an
  `agent/*` branch (looked up fresh; unreadable == fail closed). A human-
  authored PR can no longer be merged by an agent even with the toggle armed.
  Guard behavior tests 77 → 83 cases, all green.

- **Guards rebuilt as whitelists after four adversarial review rounds
  (2026-08-06).** Rounds of a three-lens panel (bypass / bash-semantics /
  contract-consistency, each finding proven by executing the hook) showed that
  every attempt to FILTER an arbitrary shell command leaks: redirect tokens
  ended argument parsing (`git push origin agent/x >/dev/null main` really
  pushed main), wrapper prefixes and shell grammar hid the verb, `grep`'s
  line-orientation let a sanctioned first line launder a second, and gh/git
  accept flags in positions no pattern anticipated. The model is now:
  - **Whitelist the exception, refuse everything else.** A command that could
    publish must match `[cd <path> && ] git push [-u] origin agent/<branch>`
    exactly; one that could merge must match `gh pr merge <N> --squash
    --delete-branch -R <repo literal>` (or the `--disable-auto` disarm).
  - **Position-free deny** for destructive git/gh ops, so wrapper prefixes,
    global flags and alias injection cannot hide the verb.
  - **Fold to one line** before matching; split the `.claude/` walk on newlines.
  - **The toggle is human-only**: `gh variable/secret` writes and the
    `actions/variables` API route are refused, so an agent cannot arm the gate
    it is judged by. The maintainer gate root must share this repo's git object
    store, so a crafted directory cannot supply a fake `forge-lint`.
  - The loop keeps working: its read-only `gh api graphql` query and its
    review-thread mutations (`resolveReviewThread` and friends) are carved out
    by name; merge/ref mutations are not.
  Deliberate over-blocking is documented in each header — a command that merely
  MENTIONS a walled word is refused, because a false refusal costs a rephrase
  and a false allow costs the wall. 438 behavior cases green, including an
  ARMED harness (fake `gh`, `LOOP_AUTOMERGE=true`) that proves the sanctioned
  merge is still allowed rather than everything simply blocking.
  **Known limit — read this before trusting the hook:** a PreToolUse string
  guard cannot be a perimeter against an adversarial agent. Shell expansion
  ($VAR, eval, command substitution, globs, file-backed API bodies) is resolved
  after the hook runs, and the review rounds kept finding new spellings rather
  than converging. Treat these guards as accident-prevention and a speed bump;
  the real wall is server-side — branch protection (required reviews and
  checks, no force-push, restricted merge rights), which an agent's token
  cannot edit, plus the human's own review.

- **Consumer loop runs the whole queue, and false positives fixed (2026-08-06).**
  Two changes so the consumer story actually works end to end:
  - `/forge-loop` no longer stops after one issue. It cycles — re-reading state
    from GitHub each pass — shepherding open PRs to landable (review threads
    incl. bots, red CI read from the failing job log, behind-zero via
    `gh pr update-branch`) and taking the next issue, until the queue is done,
    a cap is hit, a human is needed, or a cycle makes no progress; it then
    reports what merged, what waits and why. It also accepts explicit issue
    numbers (`/forge-loop 12 13`) — **the human naming issues is the
    authorization**, which is the flow for "draft these issues, now go fix
    them"; the `forge-loop-ready` label remains the no-argument queue, and an
    agent still never selects or widens its own scope. Evals 9 → 12 cases
    (+H4 continuous run, +H5 explicit scope, +E4 no-progress stop).
  - The guards were over-blocking ordinary work: 5 of 27 realistic consumer
    commands were refused, including `git commit -m "fix: resolve merge
    conflict"` and `gh pr create --title "fix: merge conflict handling"` —
    which a dev loop produces constantly, so the loop would have jammed within
    minutes. Keyword checks now ignore the VALUES of unambiguous message flags
    (`-m`/`--message`/`--title`/`--body`/`--body-file`/`--description`/
    `--notes`), while the anchored whitelists still match the untouched
    command, so the sanctioned shapes stay exact. `-B`/`-C` is only a
    branch-force signal in checkout/switch/branch context, so the global
    `git -C <dir>` flag works again. Re-measured: **0 of 27 realistic commands
    blocked, 18 of 18 attacks still blocked**, 438 guard cases green.

- **The merge contract is now a wall, not prose (2026-08-06).** The shipped
  guard verified shape, literal repo, toggle and `agent/*` head ref, then left
  "CI green" and the rest as the agent's obligation — its own closing comment
  said so. On a consumer repo with workflows but **no branch protection**,
  `gh pr merge` succeeds regardless of check status, so green-before-merge was
  an instruction an agent could simply not follow. Both guard editions now read
  the PR's real state from GitHub before letting the merge through and refuse
  unless: every check has CONCLUDED green (queued/running counts as not green),
  no `human:*`/`automerge:halt` label is on the PR and no open `automerge:halt`
  issue exists, the diff touches no protected path (`.github/`, `.claude/`,
  `.env*`, auth/payments/billing/secrets, infra, containers, `*.tf`), the PR is
  open, not BEHIND and not conflicted, and no review thread is unresolved
  (bots included). Unreadable state — or a missing `jq` — fails closed. A repo
  with no CI configured still merges, since there is nothing to be green.
  Evals: /automerge 9 → 11 (+E4 red/pending CI, +E5 the other conditions);
  new 26-case contract harness drives each condition through a fake `gh`.

- **Review is now required to exist, and a rejection can't be merged over
  (2026-08-06).** Two related holes: (1) nothing shipped a reviewer, so on a
  repo with no review bot and nobody watching, "review requested" was a request
  to nobody — and zero reviews meant zero threads, which the contract read as
  "feedback resolved"; (2) no approval check existed anywhere, so a human who
  requested changes with only a review SUMMARY (no inline comment) created no
  thread, and the merge would have gone through over an explicit rejection.
  Now, in both guard editions:
  - `reviewDecision` is read from the PR. `CHANGES_REQUESTED` is a hard block,
    thread list irrelevant.
  - An APPROVED decision is required by default — GitHub forbids self-approval,
    so an approval necessarily came from someone else. A project with no
    reviewer opts out **deliberately** with `LOOP_REQUIRE_APPROVAL=false`,
    which makes the loop's fresh-context verifier and CI the entire gate; unset
    means required, so the safe state is the default.
  - An agent can no longer grant or clear its own verdict: `gh pr review
    --approve`, `--request-changes`, review dismissal, and the
    `pulls/<n>/reviews` REST routes are all refused.
  `/automerge on` now settles the review policy with the human as a setup step
  (does a reviewer exist? if not, choose verifier-only or leave merging to a
  human) and `/automerge` status reports which policy is in force. `/forge-loop`
  requests review from someone who actually exists — bot, CODEOWNERS, or named
  reviewers — says so plainly in the run report when the repo has none, posts
  the verifier's verdict on the PR for auditability, and reads `reviewDecision`
  on the return path instead of trusting an empty thread list.
  Evals: /automerge 11 → 14 (+E6 changes-requested with no thread, +E7 no
  reviewer at all, +A4 self-approval/dismissal); contract harness 26 → 34 cases.

- **Approvals are bound to the head commit (2026-08-06).** Requiring
  `reviewDecision == APPROVED` was not enough: GitHub keeps that decision at
  APPROVED after new commits are pushed, unless the repo enables "dismiss stale
  approvals" branch protection — which most consumer repos do not. So a
  reviewer could approve commit `aaa`, the loop's own return path could push
  `bbb`/`ccc` (a CI fix, a thread fix, or the merge commit `gh pr update-branch`
  creates), and the guard would still read APPROVED and merge code nobody
  reviewed. Both guard editions now fetch `headRefOid` alongside the rest of the
  PR state and query approving reviews with the commit each was submitted
  against; the merge passes only if some APPROVED review's `commit.oid` equals
  the current head. A stale-only approval blocks with both short oids and the
  recovery path (re-request review — never dismiss or self-approve). Unreadable
  reviews fail closed. `CHANGES_REQUESTED` still hard-blocks regardless, and
  `LOOP_REQUIRE_APPROVAL=false` still bypasses the approval requirement
  entirely, so freshness is moot on that path.
  - **Ordering rule, or the loop flaps:** any push after approval invalidates
    it, `gh pr update-branch` included. The loop docs (consumer command,
    maintainer playbook, merge-step contract) now teach approve-LAST — threads
    → CI → behind-zero → gate → *then* request review on the final head — and
    state that a stale approval means re-request, not malfunction. Reports and
    `/automerge` status distinguish "approved (current head)" from "approved
    (stale — re-request)", since GitHub's UI shows both identically.
  - `/automerge on` now also recommends enabling "dismiss stale pull request
    approvals" where the human controls branch protection: the server-side twin
    of this check, and one an agent's token cannot switch off.
  - **Tests now ship with the change.** Earlier guard work was validated by a
    session-local harness that never landed, so its results were not
    reproducible. `maintenance/tests/` adds an offline runner and a fake `gh`
    shim serving per-fixture JSON; 31 cases drive both guard editions through
    fresh/stale/opt-out/rejection/unreadable states, prove the legitimate
    commands (`gh pr edit --add-reviewer`, `gh pr comment`, `gh pr view --json`)
    still pass, and prove an agent still cannot approve or dismiss. Maintainer
    -only — nothing is wired into `install.sh`. Evals /automerge 14 → 16
    (+E8 stale approval, +H4 approve-last ordering).

- **A broken wall pattern now refuses instead of going quiet (2026-08-06,
  review follow-up).** `grep` exits 0 on match, 1 on no-match and >1 on a regex
  ERROR — and the guards' `has`/`hasw` helpers read anything non-zero as "no
  match". So a typo in any pattern would have switched that wall off silently,
  with no failing test and no error anyone would see. The helpers now
  distinguish the three cases and refuse the command when a pattern cannot
  compile, so a guard bug fails closed rather than open. Verified by injecting
  an uncompilable pattern into a copy of the guard: the command is blocked with
  an explicit "wall pattern failed to compile" message. The `.claude/` glob
  detection that prompted this (flagged in review for its `[*?[]` bracket
  expression, which is valid ERE but easy to get wrong) is rewritten as plain
  alternation, and the committed suite gained 11 cases covering each glob
  spelling — `.claude/set*.json`, `.cla*/set*.json`, `.cla?ude/…`, `//` and
  `/./` — plus the reads that must still pass. Suite 31 → 42 cases.
