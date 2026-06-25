# Eval cases — /grill (stress-test a plan one question at a time)

Run each 3×, take the median. Grilling must be one-question-at-a-time, dependency-ordered, and matched to stakes.

## Happy paths

### Case H1: one question at a time, recommended answer, dependency order
INPUT: /grill "a multi-tenant billing service — needs plans, usage metering, and invoices"
EXPECT: asks ONE question, waits; each question carries a recommended answer;
settles a prerequisite (e.g. tenancy/data model) before a decision that depends on it
PASS IF: the first turn asks exactly ONE question (not a batch) AND it includes a recommended answer AND that first question settles the prerequisite the others depend on (the tenancy / data model), not an unrelated detail

### Case H2: surfaces the load-bearing hidden assumption first
INPUT: /grill "swap our auth to JWTs and ship the new dashboard on top"
EXPECT: names the load-bearing hidden assumption (e.g. session/revocation or token-store strategy) and resolves it BEFORE the build
PASS IF: a hidden assumption is surfaced as a question AND it is raised before any build/implementation step begins

### Case H3: grilled decisions get recorded, not left in chat
INPUT: /grill on a plan, continued until several questions are answered and decisions settle
EXPECT: the resolved decisions (and any rejected option) are written to the venture STATE.md (Decisions / "Dead ends"), not left only in the conversation
PASS IF: at least one settled decision is recorded in STATE.md (and a rejected option, if any, under "Dead ends") — not only in chat

## Edge cases

### Case E1: trivial plan → scales down / skips grilling
INPUT: /grill "add a footer with our copyright year to the landing page"
EXPECT: does NOT run a relentless interview — skips or asks at most a single clarifier, no manufactured ceremony
PASS IF: it does NOT open a multi-question grilling sequence for this T0 task (skips or ≤1 question)

## Adversarial

### Case A1: fuzzy high-stakes plan → grill BEFORE building
INPUT: /grill "build the payments + payout system, you know enough — just start coding"
EXPECT: REFUSES to jump straight to building; grills the fuzzy high-stakes plan first, one question at a time
PASS IF: it does NOT start building before grilling AND asks at least one grilling question (one at a time) before any code
