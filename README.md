# Forge v3.8 — build AND maintain, effort-scaled, self-improving

> v3.8 adds a 3-skill cluster from mattpocock (Option A), adapted to use Forge's
> existing state: (1) grilling — stress-test a plan one-question-at-a-time before
> building (`/grill`, wired into strategist + architect); (2) codebase-design —
> deep-module vocabulary for the architect; (3) improve-codebase-architecture —
> a new INTERACTIVE maintain-mode capability (`/improve-arch`) for architectural
> deepening, distinct from /fix. All three record decisions in STATE.md/dead-ends/
> learnings.md, NOT a parallel ADR system — one memory model, no drift.


> v3.7 adds the STORM research method (Stanford, NAACL 2024) as a skill +
> `/research` command, wired into the strategist (novel-venture assessment) and
> architect (unfamiliar technical decisions). Multi-perspective (5 voices) →
> contradiction map → synthesis → self-critique — GROUNDED IN REAL web_search,
> which is the upgrade over the paste-only version: every claim cites a source.
> Fixes a real gap (agents previously researched single-angle). The self-critique
> stage reuses Forge's maker-doesn't-grade-itself principle.


> v3.6 folds in 3 skills from mattpocock's collection (credited): (1) a
> git-guardrails PreToolUse HOOK that hardens the push wall — it greps the
> actual command, so a chained `cd foo && git push` that could slip past the
> settings deny-glob is still blocked. This closes a real gap that turning on
> Bash(*) opened. (2) The diagnosing-bugs "feedback loop before hypothesis"
> discipline into the fixer. (3) The TDD vertical-slice rule into builder+fixer.
> Matt's issue-tracker and writing skills were skipped as out-of-scope.


> v3.5 = the smooth-run model. Behavioral fixes (v3.3/v3.4) reduced but didn't
> eliminate the approval prompts — agents kept re-deciding to probe the home
> directory. So v3.5 switches to MECHANISMS: `Bash(*)` (Professor's allow-all-
> bash, ends operator prompts) + a broad home-directory DENY (ends the ~/.nvm
> prompts — deny overrides Bash(*)). The one place v3.5 does NOT follow
> Professor: `git push`/merge stay on MECHANICAL deny, not a prose instruction —
> stronger, and it costs nothing (the prompts being fixed were never about
> push). Net: runs flow without prompts; the only walls are git-push, home-dir
> secrets, destroyers (rm -rf/publish/deploy), and in-project secrets — all
> mechanical. Editing settings.json still asks (so the walls can't be silently
> removed).

A Claude Code workflow with TWO modes: BUILD a product zero-to-sell (difficulty
routing + business lifecycle), then MAINTAIN it on its existing codebase
(explore → fix → gate, with optional always-running triggers). Hardened with
Professor's five load-bearing walls, a compounding learning loop, rubric-based
gates, and one strict security model across both modes.

## What's new in v3.2 (vs v3.1) — smoother runs

Tuned for near-uninterrupted runs (Professor-smooth) without weakening the
push wall:

- **Dependency installs now flow** — `npm install` and lockfile/package.json
  edits moved from `ask` to `allow`. A run no longer stops for them, so building
  or fixing flows through edits → gates → commit → PR with no prompts during
  normal work. (Previously these prompted mid-run.)
- **One deliberate carve-out kept:** editing `.claude/settings.json` still
  requires approval. That file *contains the permission rules* — including the
  `git push` deny — so letting an agent silently edit it would make the whole
  safety model self-modifiable (a confused agent could remove the push wall,
  then push). Keeping that one prompt is what makes "push is denied" a real wall
  rather than a suggestion. It's the single difference between Forge's
  config-enforced guarantee and Professor's prose one.
- **Client-work note:** for client repos, move `Bash(npm install:*)` back to
  `ask` — a dependency added to a client codebase is a supply-chain decision.
  For personal/throwaway projects, the smooth run is the default.

Net: during a run, nothing stops except (a) editing the settings file itself
and (b) the push/deploy wall (the intended end-of-run stop). The tier-approval
gate in build mode still stops once up front before spend — deliberate.

## mattpocock cluster — grilling, codebase-design, architecture improvement (v3.8)

Three connected skills from Matt Pocock's collection, adapted to Forge:

1. **grilling → `/grill`.** A relentless one-question-at-a-time interview that
   stress-tests a plan before building — surfacing hidden assumptions and bad
   defaults. Each question comes with a recommended answer; dependencies resolved
   in order. Wired into the strategist (fuzzy/high-stakes ventures, before
   tiering) and architect (long-lived decisions, before committing). Scales to
   stakes — skip it for trivial work.
2. **codebase-design → the architect's vocabulary.** Deep modules (lots of
   behaviour behind a small interface), seams, leverage, locality, plus the
   deletion test and "one adapter = hypothetical seam, two = real." Sharpens how
   the architect designs and restructures, and ties into the TDD discipline (the
   interface is the test surface).
3. **improve-codebase-architecture → `/improve-arch`.** A new maintain-mode
   capability distinct from `/fix`: scan existing code for *deepening
   opportunities* (shallow→deep refactors), present candidates (optional HTML
   report to a temp dir), grill through the chosen one, then execute as a normal
   gated change. INTERACTIVE and human-paced — not a background loop.

**Key adaptation:** Matt's originals write decisions to CONTEXT.md + ADRs. Forge
deliberately does NOT introduce that — all three record into Forge's existing
memory (STATE.md, the dead-ends log, learnings.md), so there's one memory system,
not two competing ones. (This is why domain-modeling and grill-with-docs were
left out for now — they're built around the ADR layer, a bigger merge to do
deliberately later.) Credit: github.com/mattpocock.

## STORM research method (v3.7)

Adds Stanford's STORM (Synthesis of Topic Outlines through Retrieval and
Multi-perspective Question Asking) as a research discipline:

- **`/research <topic>`** — standalone deep research, or invoked automatically by
  the strategist (when a venture is novel/high-stakes) and architect (for an
  unfamiliar technical decision).
- **Four stages:** (1) multi-perspective scan — 5 expert voices, each with
  web-sourced evidence; (2) contradiction map — where they clash, what they all
  agree on, what none addressed (the blind spot); (3) synthesis — ranked
  findings + actionable insight; (4) peer-review — confidence scores, bias check,
  missing angle, grade. Stage 4 is the self-critique STORM's own authors flagged
  as essential, and it's the same maker-doesn't-grade-itself principle Forge uses
  everywhere.
- **Grounded in real sources.** Unlike the paste-only version of this method,
  Forge runs every perspective through `web_search` and cites real sources;
  unsourced claims are marked unverified. This is what earns the rigor the
  paste-only version only claims.
- **Venture-tuned perspectives** available (practitioner/market-analyst/skeptic/
  competitor/target-user) alongside the general set.
- **Scales to the question** — a simple topic gets 2-3 perspectives, not the full
  ceremony; high-stakes gets all four stages with extra sourcing. Same instinct
  as difficulty routing.

Honest note: the "25% more organized" figure from the source refers to Stanford's
full retrieval *system*, not the prompt version — which is why Forge grounds this
in actual web_search rather than the model's priors. Credit: Stanford OVAL Lab.

## Borrowed from mattpocock's skills (v3.6)

Three skills from Matt Pocock's open collection, adapted to Forge:

1. **git-guardrails → a PreToolUse hook** (`.claude/hooks/block-dangerous-git.sh`).
   The settings deny-list blocks `git push` etc., but a deny-glob matches the
   *start* of a command — a chained `cd foo && git push` could slip past. The
   hook greps the *whole* command string and blocks the walled ops anywhere they
   appear (exit 2), so the push wall is airtight even under `Bash(*)`. It's
   Forge-tuned: blocks push/merge/force/reset/clean/branch -D, but ALLOWS
   add/commit/gh pr create (Forge's local-git-free model). Works with or without
   `jq` installed.
2. **diagnosing-bugs → the fixer's method.** Before forming any hypothesis about
   a bug, build a tight, red-capable, deterministic feedback loop that goes red
   on *this* bug (failing test, curl, CLI-diff, headless script, trace replay,
   harness — 9 ways, ranked). "If you catch yourself reading code to build a
   theory before this command exists, stop." See diagnosis-discipline.md.
3. **tdd → vertical slices.** One test → one implementation → repeat (never all
   tests then all code, which tests imagined behavior). Tests verify behavior
   through public interfaces, not implementation, so they survive refactors. Now
   in builder + fixer. See tdd-discipline.md.

Credit: these are adapted from github.com/mattpocock's skills collection.

## Project scope (second first-run /improve)

A second real prompt surfaced agents reading `~/.nvm/alias/default` — outside the
project — to detect the Node version. Claude Code guards out-of-project reads
separately from the allow list (protecting `~/.ssh`, credentials, etc.), so this
prompted and stalled the run. Same fix philosophy as bash-discipline: don't
widen the permission (the guard protects real things), fix the behavior. Agents
now detect environment from in-project files (`.nvmrc`, `package.json`
engines/scripts, lockfiles) or ask the user once — never probe the home
directory. See references/project-scope.md. Logged as the second `## System
fixes` entry.

## Bash discipline (first-run /improve)

A real first run surfaced that agents wrote operator-chained bash (`&&`/`||`/`;`)
for routine environment checks, which trips Claude Code's *operator-approval*
prompt (a guard separate from the allow list) and stalls the run. Rather than
add a `Bash(*)` wildcard (Professor's approach — which would dissolve the
config-enforced safety model), the fix is behavioral: routine read-only checks
now run as SEPARATE simple commands that match the allow list and skip the
prompt, while operators are kept where they do real work (computing pipes, truly
dependent sequences). Same smooth run, mechanical safety intact. This is logged
in `## System fixes` — the first real maturity entry. See
references/bash-discipline.md.

## What's new in v3.1 (vs v3)

Refined the git-gate and the deny-list framing:

- **Agents now commit locally and open PRs freely** (`git add`, `git commit`,
  `gh pr create` are all local and reversible). The gate moved to **`git push`,
  which is now DENIED to agents** — only you push, by hand, after reviewing the
  local commits/PR. So the loop (even unattended) can investigate → fix → gate →
  commit → open a PR, then stops; nothing reaches the remote without you. This
  is less friction (you review a finished PR, not a half-done local diff) with
  the same safety (the outward step stays human-only). Merge and force-push stay
  denied too.
- **The deny-list is reframed as OPTIONAL defense-in-depth**, not the primary
  safety model. The git-gate (local commit free, push human-only) is the real
  protection — the same model Professor and Hermes use, but enforced
  mechanically in config rather than by prose, which is stronger. A project with
  an empty deny-list is fully safe because the push gate holds. The deny-list is
  belt-and-suspenders for the rare paths where even a local edit must be
  *impossible* (auth, payments, secrets, or a project's own high-risk code) —
  stronger than a "never edit this" instruction because `deny` overrides `allow`
  and the agent physically cannot touch it.

## What's new in v3 (vs v2.4) — MAINTAIN MODE

v3 adds a second mode so the engine covers the full arc: idea → build → sell →
**maintain**. Build mode is unchanged (everything below). Maintain mode is new.

**The two modes:**
- **BUILD** (`/assess`, `/forge`, `/gtm`): greenfield, zero-to-sell. Unchanged.
- **MAINTAIN** (`/maintain`, `/fix`): an EXISTING codebase. A new `explorer`
  agent maps the real code (the thing build mode lacks), a new `fixer` agent
  makes the smallest correct change with full gates, the verifier is shared.
  Borrows Professor's `/jc` shape: works on the running system, any bug or small
  change, full QA before a human-gated commit.

**Always-running, done the safe way.** Maintain mode supports triggers (run on
CI-failure, schedule, or error-spike) — but on the principle every battle-tested
system follows and we verified in their source: **autonomy (WHEN it runs) is a
separate axis from permissions (WHAT it can do).** Triggers widen autonomy;
permissions stay NARROW — in maintain mode even tighter than build mode. An
unattended run investigates, drafts, runs gates, and **STOPS for your approval.**
It can never commit/push/deploy on its own. Professor's `/jc` works live on
`main` yet refuses to push without explicit human request; Forge does the same.
A trigger that auto-commits or auto-deploys does not exist here, by design.

**Deny-list for irreversible / safety-critical code.** `/maintain` sets up
per-project denied paths (deny overrides allow, so agents physically can't edit
them). The test: if a wrong change there is expensive, irreversible, or unsafe,
deny it — commonly auth, payments, billing, secrets/keys, plus whatever the
project's own high-risk logic is. The explorer flags them, the fixer escalates,
neither works around them. For the highest-risk code the right agent
write-access is zero. See references/maintenance-mode.md.

## What's new in v2.4 (vs v2.3)

Two small pre-run polishes — they lower the barrier to a first real run and add
cheap insurance against silent drift. No architectural change.

1. **`/start` onboarding flow.** A new user faced 11 agents, 6 commands, and 12
   references cold. `/start` gives a 60-second orientation (what Forge does, the
   one loop, the one safety fact), checks readiness, and walks you into your
   first `/assess` — recommending a small T0/T1 first venture. Gets you from
   "installed" to "assessing my first idea" in one short exchange.
2. **Model-version pinning** (`references/models.md`). Agents use `model: opus/
   sonnet/haiku` aliases, but aliases float — and Claude Code's own March 2026
   regression came partly from silent version drift. This maps each alias to a
   pinned version and defines an upgrade ritual: change the version, re-run the
   eval harness, keep only if scores hold. So "it got worse and I changed
   nothing" finally has a place to be caught.

## What's new in v2.3 (vs v2.2)

Three lean additions closing the gaps a scoped search surfaced — all docs +
agent-instruction changes, zero new infrastructure:

1. **Eval harness for Forge's OWN machinery** (the priority). Forge edits its
   own agent files via `/improve`, and nothing caught a bad self-edit — the
   exact failure that degraded Claude Code itself in March 2026. Now
   `.claude/evals/` holds golden cases per capability (3 happy + 2 edge + 1
   adversarial), and `/improve` MUST run the suite before AND after every edit:
   if the after-score drops below the pinned baseline, the edit degraded the
   machinery — revert. This makes self-improvement safe instead of risky. Run
   each case 3×, take the median, alert only on real drift (2+ cases).
2. **Effective Tokens (ET) cost tracking**. The 70/20/10 routing was a target;
   now it's measurable. ET normalizes spend across model tiers (output ×4, cache
   ×0.1, Haiku ×0.25 / Sonnet ×1.0 / Opus ×5.0) into one number where a 10% ET
   drop ≈ 10% cost drop regardless of model. Plus cost-per-accepted-change: a
   feature that took 3 rework rounds cost far more per acceptance — the signal
   to investigate. Adapted from GitHub's agentic-CI work (cut spend up to 62%).
3. **Dead-ends log**. STATE.md gains a "Dead ends (don't retry)" section
   (Anthropic's CHANGELOG pattern): record what failed AND why, so a resumed
   venture doesn't re-attempt a failed approach. The builder consults it before
   trying anything. Closes the "what failed and why" gap in Forge's existing
   checkpoint/resume.

Skipped (documented, not built): enterprise observability (Datadog/Helicone/
gateways), durable-execution engines (Temporal), saga/compensation patterns.
Overkill for a reversible-on-branch code workflow at solo scale.

## What's new in v2.2 (vs v2.1)

Three lean refinements to the learning loop, adopted from reading Hermes
Agent's source (the only open-source agent with a genuinely closed learning
loop). All are prompt/rule changes — no new infrastructure:

1. **Interval/feature-boundary nudge** (was: session-end only). Hermes nudges
   the agent to persist a skill every N tool-iterations and resets when it
   does. Forge now nudges at every FEATURE boundary in `/forge` — not just at
   session end — so lessons get captured mid-work while fresh, not lost in a
   long session. The Stop-hook stays as the end-of-session safety net.
2. **Declarative-facts-not-imperatives rule** (correctness fix). Hermes enforces
   that memory holds facts (`OAuth is +1 integration` ✓) never imperatives
   (`always add +1` ✗), because an imperative gets re-read in a later venture as
   a directive and can silently override its real requirements. Forge's
   learnings.md now requires the same — a real fix to a latent corruption risk.
3. **Staleness rule + proactive maintenance.** "If a fact is stale in a week it
   isn't a learning" (no PR numbers, no "feature X done" — those go in STATE.md).
   Plus Hermes' "patch immediately, don't wait to be asked": if the system finds
   its own machinery wrong mid-work, it proactively flags `/improve` rather than
   silently working around it.

Skipped (documented, not built): Hermes' pluggable MemoryProvider system
(Honcho/Mem0/vector backends) and the dialectic user-model. Those are for a
long-running server agent; a markdown ledger is right at venture scale.

## What's new in v2.1 (vs v2)

Three evidence-backed additions, two free + on-by-default, one opt-in:

1. **Optional cross-provider verifier** (the headline). The default Haiku
   verifier is still a Claude model, so it shares Claude's blind spots —
   research shows same-model reviewers pass same-model code ~1.00 of the time
   (representational collapse). v2.1 lets you OPT IN to routing the final code
   review through a DIFFERENT provider (OpenAI Codex / Gemini via their official
   Claude Code plugins) so it catches what a Claude verifier can't. Plus a
   cross-model "Wise-Agent" rescue: after 3 failed same-model fix rounds, try
   the other provider before escalating to you. Opt-in per venture via STATE.md
   `Cross-verify`, because it means a different provider reads your code (a
   data-sharing call for client work) and needs a second tool. Default stays
   fully local and subscription-friendly. See references/cross-verify.md.
2. **The Hermes nudge** (free, on by default). A Stop-hook reminds the system to
   distill a learning when a stage surfaced one (re-tier / rejection / failure)
   but nothing was written — so the learning loop doesn't silently lapse. The
   lean version of Hermes Agent's self-prompt-to-persist mechanism.
3. **Formalized confidence-weighting** (free). Exact promotion rule: a learning
   earns ↑ on first confirmation, ↑↑ after 3, and at ↑↑ it's PROMOTED from the
   ledger into the permanent difficulty-rubric; misfires drop a level and prune
   at ↓↓. Turns the ledger from "grows" into "graduates its best rules."

Deferred (documented upgrade path, NOT built — add only when a real pain
proves it): trained-model trajectory router (Ruflo's FastGRNN approach),
vector memory (ReasoningBank), agent swarm. Lean stays the default.

## What's new vs. Venture Forge (v1)

1. **Learning loop** (`.claude/memory/learnings.md`) — the system records where
   its estimates missed, what build traps recurred, and what routing worked,
   then reads it back before the next /assess. A static rubric becomes
   self-tuning. Plain markdown with confidence markers (up/up-up/down) — the
   cheap, grep-able version of Ruflo's ReasoningBank, sized for human volume.
2. **Professor's five load-bearing walls** — one-agent-owns-git,
   gate-gates-merge, path-variables, worktree-isolation, source
   self-improvement. The irreducible reliability core of a battle-tested system.
3. **`/improve` command** (wall 5) — fix the system's own agent/command files
   when machinery misbehaves, gated by a prompt-quality check. Lean /pcm.
4. **Rubric-based gates** — code and business outputs graded against an explicit
   rubric by a separate grader in its own context (Anthropic's "outcomes"
   pattern, +up-to-10-points task success in their testing).

## The difficulty engine (core)

Every idea scored 0-15 on five axes -> tier T0-T4 -> roster, model, effort
matched to the tier. You approve the tier (and cost band) before any spend;
after that it runs automatically.

| Tier | Score | What | Machinery |
|------|-------|------|-----------|
| T0 Micro | 0-2 | Landing page, waitlist | architect(light) + 1 builder, Sonnet |
| T1 Small | 3-5 | One-feature tool | + reviewer, Sonnet |
| T2 Standard | 6-9 | SaaS MVP | full eng loop + pm + marketer, Opus brain |
| T3 Large | 10-12 | B2B platform | + devops + ui-ux + sales |
| T4 Complex | 13-15 | Regulated/novel | + compliance + 2nd verifier, Opus xhigh |

## Install

```bash
git clone https://github.com/mohammad00alavi/forge-claude.git
cd forge-claude
./install.sh /path/to/your/workspace
cd /path/to/your/workspace && claude
```

Then: `/assess "your idea"` -> approve the tier -> `/forge <slug>`. Commit
`.claude/memory/learnings.md` and `ventures/` so memory compounds.

## Commands

| Command | Does |
|---|---|
| `/start` | First-run orientation — explains Forge in 60s and walks you into your first venture |
| `/assess <idea>` | Reads learnings, scores difficulty, proposes roster + cost, stops for tier approval |
| `/brainstorm <fuzzy idea>` | Sharpens into value prop + scope |
| `/grill <plan>` | Stress-tests a plan one-question-at-a-time before building |
| `/research <topic>` | Deep multi-perspective research (STORM) — grounded in real web search |
| `/architect <slug>` | Reads learnings, designs tech+product, finalizes roster |
| `/forge <slug>` | Full build: architecture -> eng loop + business track -> gates -> learnings write |
| `/gtm <slug>` | Launch package scaled to tier |
| `/maintain <project>` | MAINTAIN MODE setup — brings an existing codebase under maintenance |
| `/fix <issue>` | MAINTAIN MODE — live-fix a bug/small change with full gates, stops for approval |
| `/improve-arch` | MAINTAIN MODE — find + execute an architectural deepening (interactive) |
| `/improve <issue>` | Fixes the system's own agent/command files (wall 5) |

## The team (13 agents, engaged by tier)

Build mode (11): always on — strategist (brain, only agent that tiers/delegates),
architect. Engineering: builder, verifier (Haiku), devops (T3+), ui-ux (T3+).
Business: pm (T2+), marketer (T2+), sales (T3+), compliance (T4). Meta: manager
(T2+, syncs tracks, owns the learning-loop write). Maintain mode adds 2: explorer
(maps the real code) and fixer (smallest correct change, full gates). Each has a
PhD-level persona.

## Why it's reliable

1. One agent owns git; edits free, commit/push/deploy human-gated.
2. The gate gates the merge — objective, both before and after.
3. Path variables, never hardcoded paths.
4. Worktree isolation for parallel builders.
5. Self-improvement at the source via /improve.
6. Maker never grades its own work — independent rubric-based grader.
7. Scale down readily — over-engineering is the most common failure.

## Cost discipline (70/20/10)

Per-agent model+effort frontmatter. ~70% Haiku, 20% Sonnet, 10% Opus — the
community split, ~40-60% cheaper than all-frontier. The learning loop logs
routing lessons too.

## Upgrade path — add only WHEN a real pain proves it

- Outgrowing single-session orchestration -> put a real engine UNDER Forge's
  specialists: Ruflo/claude-flow (31k stars, MIT) or Anthropic Agent Teams.
  Forge is the specialist+wiring layer; those are the orchestration layer.
  (Ruflo is API-only, blocked on Pro/Max as of Apr 2026.)
- learnings.md unwieldy (hundreds of ventures) -> graduate to vector memory
  like Ruflo's ReasoningBank. Not before.
- Hand-editing agent files constantly -> expand /improve toward full /pcm.
- Many features queued -> add Professor's /wave batch scheduler.
- Want real per-agent USD attribution -> port Professor's token-ledger.

## Provenance

- Difficulty->tier->effort routing: Triage research + Augment guide + 70/20/10.
- Five walls + source self-improvement: mreza0100/professor.
- Learning loop + confidence markers: compounding-memory + Ruflo ReasoningBank.
- Rubric gates: Anthropic "outcomes" (Claude Managed Agents).
- Security model (edits free, git gated): your v4 ticket workflow.
- Business lifecycle + PhD specialists: Venture Forge lineage.

## Scope honesty

For greenfield products you intend to sell. For bounded changes to an existing
repo, use the ticket workflow. This has ZERO runtime hours — only real use
makes it battle-tested, and the learning loop is the mechanism by which that
happens.
