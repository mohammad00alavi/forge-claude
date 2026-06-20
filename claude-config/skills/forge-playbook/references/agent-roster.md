# Agent roster — who exists, when each is engaged

Each agent has a PhD-level persona in its discipline (the persona is
load-bearing: it makes the agent argue from expertise and refuse bad ideas,
not just autocomplete). Personas are defined in the agent files themselves.

## Always-on (every tier)

- **strategist** (the orchestrator/brain) — runs `/assess`, scores difficulty,
  proposes the roster, sequences the lifecycle, delegates. PhD-level systems
  thinker. This is the only agent that decides tiers and spawns others.
- **architect** — designs both tech and (at T2+) high-level product
  architecture; finalizes the agent roster; picks the stack. PhD in software
  architecture. Read-mostly; produces specs, not code.

## Maintain-mode track (existing codebases)

- **explorer** — maps an EXISTING codebase before a fix: where the issue lives,
  current behavior, nearest test, pattern to copy, blast radius, forbidden-path
  flags. Read-only. The agent build mode lacks. Engaged by /maintain and /fix.
- **fixer** — the live-fix maker: root-cause diagnosis, failing test first,
  smallest correct diff matching existing patterns, full gates, local commit +
  PR. Never pushes (push denied) — the human reviews locally and pushes.
  Tighter rules than the builder (production code). Engaged by /fix.

(The verifier is shared across both modes.)

## Engineering track (build mode)

- **builder** — the maker. Implements features as the smallest viable diff in
  an isolated worktree. Edits and commits locally (add/commit/PR free); never
  pushes — the human pushes after local review.
- **verifier** — the checker. Independent, sees only the artifact + spec +
  gates, never the builder's reasoning. Haiku by default (cheap, no bias).
  T4 adds a second verifier.
- **devops** (T3+) — infra, CI, deploy config, environments. The only agent
  that touches deploy pipelines — and deploys are human-gated.
- **ui-ux** (T3+) — design system, accessibility, visual/interaction review.
  Advisory; uses vision to check rendered output against the goal when tooling
  allows.

## Business track

- **pm** (T2+) — product manager. Turns the value prop into a prioritized
  scope, acceptance criteria, and a backlog. PhD in product management.
- **marketer** (T2+) — positioning, messaging, GTM plan, and — scaled to tier
  — real deliverables: landing copy, pricing page copy, ad drafts, launch
  posts. PhD in marketing. Produces both strategy doc AND assets.
- **sales** (T3+) — pricing strategy, sales narrative, outreach templates,
  objection handling, demo script. PhD in sales/revenue.
- **compliance** (T4) — regulatory, privacy, legal-risk review for regulated
  domains. Flags blockers; does not give legal advice, surfaces what needs a
  human lawyer.

## Meta

- **manager** — engaged at T2+ when multiple tracks run in parallel. Keeps the
  engineering and business tracks synced, tracks the venture state file,
  resolves cross-track dependencies (e.g., "pricing page needs the final
  feature list from pm"). PhD in operations/program management. Does not build
  or write deliverables — coordinates and reports.

## The roster is emergent, not fixed

`/assess` proposes a roster from the tier. `/architect` finalizes it based on
what the project actually is. A T2 pure-frontend tool drops devops; a T1 idea
that needs Stripe pulls in a payments-review pass even though T1 normally
wouldn't. The tier is the starting point; the architecture is the deciding
vote. Always justify each agent's inclusion by the distinct output it owns.
