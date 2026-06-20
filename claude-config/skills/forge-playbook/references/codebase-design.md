# Codebase design — deep modules, seams, leverage

Adapted from mattpocock's `codebase-design` (itself drawing on Ousterhout's
"deep modules" and Feathers' "seams"). A shared vocabulary the architect uses
when designing or restructuring code. The aim: leverage for callers, locality
for maintainers, testability for everyone.

## Use these terms exactly

Consistent language is the point — don't substitute "component," "service,"
"API," or "boundary."

- **Module** — anything with an interface and an implementation. Scale-agnostic:
  a function, class, package, or tier-spanning slice. (Avoid: unit, component,
  service.)
- **Interface** — everything a caller must know to use the module correctly: the
  type signature, but ALSO invariants, ordering constraints, error modes,
  required config, performance characteristics. (Avoid: API, signature — too
  narrow, they mean only the type surface.)
- **Implementation** — what's inside the module, its body of code.
- **Depth** — leverage at the interface: how much behaviour a caller (or test)
  can exercise per unit of interface they must learn. **Deep** = lots of
  behaviour behind a small interface. **Shallow** = interface nearly as complex
  as the implementation.
- **Seam** (Feathers) — a place where you can alter behaviour without editing in
  that place; the *location* where a module's interface lives. Where to put the
  seam is its own decision, separate from what goes behind it. (Avoid: boundary —
  overloaded with DDD.)
- **Adapter** — a concrete thing satisfying an interface at a seam. Describes
  *role* (what slot it fills), not substance.
- **Leverage** — what callers get from depth: more capability per unit of
  interface learned. One implementation pays back across N call sites + M tests.
- **Locality** — what maintainers get from depth: change, bugs, knowledge, and
  verification concentrate in one place. Fix once, fixed everywhere.

## Deep vs shallow

```
DEEP (good):                 SHALLOW (friction):
┌──────────────────┐         ┌──────────────────┐
│  Small Interface │         │  Large Interface │
├──────────────────┤         ├──────────────────┤
│                  │         │ thin impl        │
│  Deep Impl       │         └──────────────────┘
│  (complex logic  │         interface ≈ implementation:
│   hidden)        │         caller must learn almost
└──────────────────┘         everything to use it
```

## Principles to apply

- **The interface is the test surface.** A deep module is testable *through its
  interface* — if you must reach inside to test it, the seam is wrong. (This ties
  directly to the TDD discipline: test behaviour through public interfaces.)
- **The deletion test** — for anything you suspect is shallow: would deleting it
  *concentrate* complexity, or just *move* it? "Concentrates" = it's earning its
  place. "Just moves it" = it's a shallow wrapper adding interface cost for no
  depth.
- **One adapter = hypothetical seam, two = real.** Don't introduce a seam/
  abstraction for a single implementation — you're guessing at the axis of
  change. Wait until a second adapter proves the seam is real.
- **Locality over premature extraction.** Pure functions extracted *just* for
  testability, where the real bugs hide in how they're called, trade locality for
  a shallow win. Prefer keeping related logic together and testing through the
  real interface.

## Where it plugs into Forge

- The **architect** uses this vocabulary when designing a venture's modules (in
  build mode) — small interfaces, clean seams, deep implementations.
- `improve-codebase-architecture` uses it to find *deepening opportunities* in
  existing code (maintain mode) — the deletion test and shallow-module detection
  are its core scan (see that reference).
- The **builder/fixer** benefit indirectly: code designed this way is the
  testable, refactor-surviving code the TDD and verification disciplines assume.
