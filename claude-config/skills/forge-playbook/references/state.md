# Per-venture state file format

One per venture: `ventures/<slug>/STATE.md`. Read first every stage, written
last. Structured for the fail→investigate→verify→distill→consult memory
progression so the system compounds instead of just accumulating.

```markdown
# Venture · <slug>

## Snapshot
- Tier: T2 (score 7/15) · approved <date>
- Value prop: <one line>
- Stack: <decided by architect>
- Gates: <typecheck/lint/test/build commands — or `MISSING` if none defined>
- Cross-verify: none   # or `codex`/`gemini` to add cross-provider review (see references/cross-verify.md)
- Roster: architect, builder, verifier(haiku), pm, marketer, manager
- Stage: forge (engineering 3/5 features, business track in progress)

## Difficulty assessment (frozen at approval)
scope 2 · novelty 1 · data 2 · integration 1 · risk 1 = 7 → T2

## Verified facts (stop guessing about these)
- <e.g. Stripe test mode keys live in .env.local, prod via host secrets>

## Decisions (with rationale — survive across sessions)
- <e.g. chose SQLite over Postgres: single-tenant MVP, can migrate later>

## In progress
- Engineering: feature "auth" → branch claude/auth → verifier round 1 FAIL
- Business: marketer drafting landing copy, awaiting pm final feature list

## Completed
- feature "landing" → PR #1 (draft, awaiting human merge)
- deliverable "positioning.md" → PASS

## Escalated to human
- <e.g. pricing number for Pro tier — needs your call>
- <e.g. domain + DNS for launch>

## Dead ends (don't retry)
<what was tried, why it failed — so a resumed session doesn't re-attempt it.
Anthropic's CHANGELOG pattern: track what failed AND why, or successive
sessions re-derive the same dead ends.>
- <e.g. tried Postgres row-level security for tenancy — too slow for MVP, used
  app-level scoping instead. Don't revisit RLS.>

## Lessons learned (distilled rules, dated)
- <YYYY-MM-DD: durable rule that applies beyond this venture>

## Cost log (Effective Tokens — see references/cost-tracking.md)
- ET by tier: Opus ~__% / Sonnet ~__% / Haiku ~__% — flag if Opus > 15%
- ET per accepted feature: <feature: ~ET> — flag outliers (rework = waste)

## Last session (resume pointer)
<date · what was done · what's next>
```

## Lean STATE (T0/T1 — don't over-build the bookkeeping)

The template above is for T2+. At T0/T1, an elaborate state file is itself
Forge's #1 failure mode (over-engineering). Use this minimal form:

```markdown
# Venture · <slug>
- Tier: T0 (score _/15) · approved <date>
- Value prop: <one line>
- Stack: <decided by architect>
- Gates: <test/build commands, or `MISSING`>
- Status: <building | done | shipped>
- Next: <the single next action>
- Dead ends: <what not to retry, or "none">
- Escalated: <anything needing the human, or "none">
```

Promote to the full template only if the venture grows past T1.

Two operational rules:
- **Write before walking away.** A stage that ends without updating STATE.md
  makes the next stage restart from zero.
- **Read at stage start.** Every stage begins by reading STATE.md + the
  relevant handoff ledger.
