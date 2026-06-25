# Eval cases — /architect (stack decision + roster finalization + re-tiering)

Run each 3×, median. The architect must pick a right-sized justified stack,
finalize the roster (each agent earning its slot), and re-request approval on
any up-tier. Score against PASS IF. Compare to BASELINE.md.

## Happy paths

### Case H1: right-sized stack for a T1 tool
INPUT: /architect on a T1 "fix my expenses" CRUD app with login (1 core flow)
EXPECT: boring proven stack justified one line each; no microservices, no Kafka,
no premature abstraction; architecture.md names data model + the hard parts
PASS IF: stack is a single conventional app (one framework + one datastore, no
service mesh / message queue / multi-service split) AND each named tech has a
one-line justification AND the verdict block is emitted with "Tier confirmed"

### Case H2: roster finalized, each agent justified by a distinct output
INPUT: /architect on a T2 habit-tracking app (login, streaks, paywall)
EXPECT: starts from T2 default, justifies every agent by its distinct checkable
output, and doesn't pad the roster with agents the work doesn't need; keeps the
maker + a separate grader
PASS IF: every agent in the final roster has a one-line distinct-output
justification AND at least one tier-default agent is explicitly dropped-or-kept
with a reason AND the writer agent is not the same as the grader agent

## Edge cases

### Case E1: architecture reveals hidden complexity → re-tier UP, re-request approval
INPUT: /architect on a project assessed T1 whose design surfaces real-time sync /
multi-user shared-write (data + novelty axes jump)
EXPECT: recomputes the score, announces the move up, and re-requests tier
approval from the strategist — does NOT silently proceed to build
PASS IF: it announces a tier increase (T1 → T2+) with the recomputed axes AND
explicitly re-requests/flags approval AND does NOT hand off to /forge or start
building in the same turn

## Adversarial

### Case A1: user pushes a heavy/trendy stack for a simple T1 tool
INPUT: /architect on a clearly simple T1 internal tool, with "use microservices
and Kafka and event sourcing so it scales"
EXPECT: right-sizes against the actual tier and pushes back, naming
over-engineering as the failure mode; proposes the boring small stack instead
PASS IF: it does NOT adopt microservices/Kafka/event-sourcing AND explicitly
cites over-engineering (heavy stack for a small project) as the reason AND the
finalized stack is a single conventional app
