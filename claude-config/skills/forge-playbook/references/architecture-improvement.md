# Architecture improvement — find and execute deepening opportunities

Adapted from mattpocock's `improve-codebase-architecture`. A maintain-mode
capability distinct from bug-fixing: scan an existing codebase for *deepening
opportunities* (refactors that turn shallow modules into deep ones), present
them, then work through a chosen one with the user. The aim is testability and
navigability.

This is an INTERACTIVE, sit-with-it tool — NOT a background/unattended loop. It
surfaces candidates and grills through the chosen one with the user. (The
autonomous maintain loop is `/fix`; this is the deliberate, human-in-the-room
architecture session.)

Built on two other references: `codebase-design.md` (the deep-module vocabulary
— use those terms exactly) and `grilling.md` (the decision loop).

## Process

### 1. Explore

Read the venture/project STATE.md first (including "Dead ends — don't retry", so
you don't re-suggest a rejected refactor). Then have the `explorer` agent walk
the codebase, noting friction — don't follow rigid heuristics, explore
organically:
- Where does understanding one concept require bouncing between many small
  modules? (poor locality)
- Where are modules **shallow** — interface nearly as complex as implementation?
- Where were pure functions extracted just for testability, but the real bugs
  hide in how they're called?
- Where do tightly-coupled modules leak across their seams?
- Which parts are untested or hard to test through their current interface?

Apply the **deletion test** to anything suspected shallow: would deleting it
*concentrate* complexity or just *move* it? "Concentrates" is the signal.

### 2. Present candidates

Present the deepening candidates to the user. A visual HTML report is optional
(write it to a temp dir, NEVER into the repo — resolve `$TMPDIR` or `/tmp`, write
`<tmpdir>/architecture-review-<timestamp>.html`, open it, tell the user the
path). A clear prose/markdown list is a fine lighter-weight alternative.

For each candidate:
- **Files** — which modules are involved.
- **Problem** — why the current architecture causes friction (in
  codebase-design terms: where's the shallowness, the leaked seam, the lost
  locality).
- **Solution** — plain-English description of the deepening.
- **Benefits** — in terms of leverage and locality, and how tests improve.
- **Before/after** — show the shallow→deep shape.
- **Recommendation strength** — Strong / Worth exploring / Speculative.

End with a **top recommendation**: which to tackle first and why. Then ask the
user which they want to explore. Do NOT propose detailed interfaces yet.

### 3. Grill through the chosen candidate

Once the user picks one, run the grilling loop (`grilling.md`) to walk the design
tree with them: constraints, dependencies, the shape of the deepened module,
what sits behind the seam, which tests survive. One question at a time, each with
your recommended answer.

### 4. Execute (gated like any change)

When the design is settled, the work is implemented through Forge's normal path:
the `fixer` (or `builder`) makes the change as the smallest correct diff,
following the TDD discipline (tests through the public interface — the deepened
module's interface IS its test surface), the `verifier` gates it, and it's
committed locally + PR'd for the human to push. A refactor is a code change like
any other — same gates, same human-pushes wall.

## Recording decisions — use Forge's state, NOT a parallel ADR system

Matt's original writes decisions to CONTEXT.md/ADRs. Forge does NOT — it keeps
one memory system:
- A settled architectural decision → the venture's STATE.md.
- A refactor rejected for a load-bearing reason → STATE.md "Dead ends (don't
  retry)" with the WHY (so a future architecture scan doesn't re-suggest it).
- A reusable design lesson → the learning loop (learnings.md).

## Scope honesty

This finds and executes *architectural* improvements — a different job from
`/fix` (bug-fixing). It's interactive and human-paced. Don't run it unattended,
and don't let a "deepening" balloon into a rewrite: each candidate is a bounded,
gated change, and the smallest diff that achieves the depth wins.
