# TDD discipline — vertical slices, behavior not implementation

Adapted from mattpocock's `tdd`. Forge already says "failing test first"; this
sharpens *how* to do it so the tests are actually good.

## Core principle

**Tests verify behavior through public interfaces, not implementation details.**
Code can change entirely; tests shouldn't. A good test reads like a
specification — "user can checkout with valid cart" tells you exactly what
capability exists — and survives refactors because it doesn't care about
internal structure.

**Warning sign of a bad test:** it breaks when you refactor but behavior hasn't
changed. If renaming an internal function fails a test, that test was testing
implementation, not behavior. Avoid: mocking internal collaborators, testing
private methods, asserting via external means (querying the DB directly instead
of going through the interface).

## The anti-pattern: horizontal slicing

**DO NOT write all tests first, then all implementation.** Treating RED as
"write all tests" and GREEN as "write all code" produces bad tests:
- written in bulk, they test *imagined* behavior, not *actual*;
- they test the *shape* of things (signatures, data structures) rather than
  user-facing behavior;
- they become insensitive to real changes — pass when behavior breaks, fail
  when behavior is fine;
- you outrun your headlights, committing to test structure before understanding
  the implementation.

```
WRONG (horizontal):          RIGHT (vertical):
  RED:   test1..test5          RED→GREEN: test1→impl1
  GREEN: impl1..impl5          RED→GREEN: test2→impl2
                               RED→GREEN: test3→impl3
```

## The rule: vertical slices via tracer bullets

**One test → one implementation → repeat.** Each test responds to what you
learned from the previous cycle. Because you just wrote the code, you know
exactly what behavior matters and how to verify it.

## Prefer integration-style tests

Exercise real code paths through public APIs. They describe *what* the system
does, not *how*. These survive refactors and actually catch regressions — which
is the entire point of having them (and the thing Forge's eval harness and the
fixer's regression loop both depend on).

## How this fits Forge

The builder and fixer both write tests. This discipline keeps those tests
*durable* (behavior-focused, refactor-surviving) and *honest* (vertical, so they
test real not imagined behavior). A test suite built this way is what makes the
verifier's gate and the eval baseline meaningful instead of brittle.
