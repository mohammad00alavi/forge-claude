# Difficulty rubric — the five-axis score (0–15)

Score each axis 0–3. Sum → tier (see SKILL.md table). Be honest and lean
*low* when uncertain; you can always re-tier up after architecture reveals
hidden complexity. Over-scoring wastes tokens on machinery the project
doesn't need.

## Axis 1 — Scope (how much surface area)
- **0** Single page/screen, one job.
- **1** A few views, one core feature.
- **2** Several features, multiple flows, a real information architecture.
- **3** Many features across multiple user types or domains.

## Axis 2 — Technical novelty (known vs. unsolved)
- **0** Entirely boilerplate; a template covers it.
- **1** Standard patterns, minor custom logic.
- **2** Some genuinely hard parts (realtime, complex algorithms, perf work).
- **3** Novel/unsolved — research required, no obvious reference.

## Axis 3 — Data & state complexity
- **0** No persistent data, or static content only.
- **1** Simple CRUD, one or two entities.
- **2** Relational data, non-trivial state, caching/sync.
- **3** Complex data model, migrations, consistency/scale concerns.

## Axis 4 — Integration surface (external systems)
- **0** None — self-contained.
- **1** One simple integration (a form handler, analytics).
- **2** Payments, auth provider, a couple of third-party APIs.
- **3** Many integrations, webhooks, multi-system orchestration.

## Axis 5 — Risk & compliance (how costly is "wrong")
- **0** Nothing irreversible; no sensitive data.
- **1** Basic auth, some user data.
- **2** Payments/PII, real security surface.
- **3** Regulated domain (fintech, health), legal/compliance exposure.

## Worked examples

- **Newsletter waitlist page**: scope 0, novelty 0, data 0 (or 1 if storing
  emails), integration 1, risk 0 → **1–2 = T0**.
- **A "fix my expenses" CRUD app with login**: scope 1, novelty 1, data 1,
  integration 1, risk 1 → **5 = T1**.
- **Marketplace MVP with Stripe + listings + chat**: scope 2, novelty 2,
  data 2, integration 2, risk 2 → **10 = T3** (note: payments pushes risk up).
- **A budgeting SaaS that connects to bank APIs**: scope 2, novelty 2, data 3,
  integration 3, risk 3 → **13 = T4** (regulated + bank integration).

## Re-tiering rule
If `/architect` uncovers that the real build is materially simpler or harder
than the assessment assumed, recompute the score, announce the change, and
re-request tier approval if it moved up (down-tiering needs only a heads-up).
