# Grilling — stress-test a plan before building

Adapted from mattpocock's `grilling`. A relentless one-question-at-a-time
interview that surfaces hidden assumptions, unresolved dependencies, and bad
defaults *before* code is written. Forge's default instinct is assess-then-
proceed; grilling is the deliberate pause for when proceeding on an untested
assumption would be expensive.

## The core technique

Interview the user relentlessly about every aspect of the plan or design until
you reach shared understanding. Walk down each branch of the design tree,
resolving dependencies between decisions one by one.

**Rules that make it work:**
- **One question at a time.** Wait for the answer before the next question.
  Asking several at once is bewildering and produces shallow answers.
- **Always offer your recommended answer** with each question — don't just
  interrogate; propose. The user reacts to a concrete suggestion faster than to
  an open prompt.
- **If a question can be answered by exploring the codebase, explore instead** —
  don't ask the user what you can find yourself. (Respect project-scope: read
  in-project files, not the home directory.)
- **Resolve dependencies in order** — if decision B depends on decision A,
  settle A first. Don't jump around the tree.

## When to grill (don't grill everything)

Grilling is for high-stakes or high-uncertainty work where a wrong assumption is
costly. Match it to the stakes, same instinct as difficulty routing:
- **Skip it** for T0/T1 or anything well-understood — grilling a landing page is
  friction.
- **Use it** before a T2+ build when scope is fuzzy, before an architectural
  decision with long-lived consequences, or before a maintain-mode refactor that
  touches many call sites.
- **Always** when the user explicitly asks to stress-test a plan, or uses a
  "grill me / poke holes / stress-test" phrasing.

## Where it plugs into Forge

- The **strategist** can grill during `/assess` when a venture is fuzzy or
  high-stakes — turning vague requirements into resolved decisions before tiering.
- The **architect** can grill before finalizing a design with long-lived
  consequences (a framework choice, a data model, a seam placement).
- `improve-codebase-architecture` uses grilling as its decision loop (see that
  reference).

## Recording the outcome (use Forge's state, NOT a parallel system)

When grilling resolves a decision that matters later, record it where Forge
already keeps memory — do NOT introduce a separate ADR/CONTEXT.md system:
- A resolved scope/design decision → the venture's STATE.md (Snapshot or a
  "Decisions" note).
- A decision that should never be re-litigated (an approach tried and rejected
  for a load-bearing reason) → STATE.md "Dead ends (don't retry)" with the WHY.
- A reusable estimation/design lesson → the learning loop (learnings.md).

This keeps one memory system, not two. Grilling sharpens the plan; Forge's
existing state remembers it.
