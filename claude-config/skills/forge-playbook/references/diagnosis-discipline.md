# Diagnosis discipline — build the feedback loop BEFORE the hypothesis

Adapted from mattpocock's `diagnosing-bugs`. This is the discipline the fixer
uses for any non-trivial bug or regression in maintain mode. The core idea is
counterintuitive and it's the whole point:

## The one rule

**Before you theorize about the cause, build a tight, red-capable feedback
loop — a single command that goes RED on THIS specific bug and GREEN once
fixed.** If you have that, bisection / hypothesis-testing / instrumentation all
just consume it and you WILL find the cause. If you don't, no amount of staring
at code will save you.

> If you catch yourself reading code to build a theory before this command
> exists — STOP. Jumping straight to a hypothesis is the exact failure this
> prevents. No red-capable command, no diagnosis.

## Ways to build the loop (try roughly in this order)

1. **Failing test** at whatever seam reaches the bug (unit / integration / e2e).
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout vs known-good.
4. **Headless browser script** (Playwright) — drives the UI, asserts on
   DOM/console/network.
5. **Replay a captured trace** — save a real request/payload/event to disk,
   replay it through the code path in isolation.
6. **Throwaway harness** — minimal subset of the system (one service, mocked
   deps) exercising the bug path with one function call.
7. **Property / fuzz loop** — for "sometimes wrong output", run many random
   inputs and catch the failure mode.
8. **Bisection harness** — if it appeared between two known states, automate
   "boot at state X, check, repeat" for `git bisect run`.
9. **Differential loop** — same input through old vs new (or two configs), diff.

## Tighten the loop (treat it as a product)

Once you have *a* loop, make it:
- **Faster** — cache setup, skip unrelated init, narrow scope. (A 2-second
  deterministic loop is a superpower; a 30-second flaky one is barely a loop.)
- **Sharper** — assert on the *specific symptom the user reported*, not "didn't
  crash".
- **More deterministic** — pin time, seed RNG, isolate filesystem, freeze
  network.

## Non-deterministic bugs

The goal isn't a clean repro but a **higher reproduction rate**. Loop the
trigger 100×, parallelize, add stress, narrow timing windows. A 50%-flake bug
is debuggable; 1% is not — raise the rate until it's debuggable.

## Completion criterion (before moving to the fix)

Done when you can name ONE command — a script path, a test, a curl — that you
have ALREADY RUN at least once (paste the invocation + its output) and that is:
- **Red-capable** — drives the actual bug path, asserts the user's EXACT
  symptom, can go red on this bug and green once fixed.
- **Deterministic** — same verdict every run (or a pinned high repro rate).
- **Fast** — seconds, not minutes.
- **Agent-runnable** — runs unattended.

## When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to
an environment that reproduces it, (b) a captured artifact (HAR, log dump,
screen recording with timestamps), or (c) permission to add temporary
instrumentation. Do NOT proceed to hypothesize without a loop.

## Why this fits Forge

The fixer already writes a failing test first — this generalizes and sharpens
it: the failing test is just *one* of ten ways to build the loop, and the
discipline is to have SOME red-capable signal before forming any theory. Build
the right loop and the bug is 90% fixed.
