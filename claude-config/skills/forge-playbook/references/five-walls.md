# The five load-bearing walls (hardening from Professor)

These five rules are non-negotiable structural guarantees, adapted from
mreza0100/professor's "five load-bearing walls" — the parts of its
architecture that 22 release tags proved you cannot remove. They make the
system safe to run with less supervision. Touch anything else; leave these.

## Wall 1 — One owner for git, and the remote is the human's

Only the **builder** (and the **fixer** in maintain mode) runs `git`. Local
`add`/`commit`/`gh pr create` are **free**; `git push`, `git merge`, and deploy
are **DENIED** — the human pushes after local review (enforced mechanically by
the settings deny-list plus the git-guardrail hook). No other agent — not the
verifier, not devops, not any business agent — runs git. This:
- centralizes commits behind one reviewed path,
- prevents agents racing each other for a commit,
- makes "what got committed" auditable to one source,
- guarantees nothing reaches a remote without you.

If an agent needs something committed, it asks the builder/fixer (or surfaces it
to the human). devops PREPARES deploys but never runs them.

## Wall 2 — The gate gates the merge (objective, both sides)

Code is verified on the worktree branch BEFORE any merge is proposed, and the
acceptance criteria are re-checked after. A gate is something that can fail the
work without a human in the room: typecheck, lint, test, build. "Looks done"
is not a gate. A second agent's opinion is not a gate. And zero tolerance for
"pre-existing failures" — if the gate is red when a venture stage starts, that
stage leaves it greener than it found it.

## Wall 3 — One canonical path layout (a fixed convention)

Every venture uses one predictable layout, so any agent finds state without
guessing:

| Path | Meaning |
|---|---|
| `ventures/<slug>/` | the venture directory |
| `ventures/<slug>/STATE.md` | the single source of venture truth |
| `ventures/<slug>/deliverables/` | shipped artifacts |
| `.claude/handoffs/<slug>.md` | the agent-to-agent handoff ledger |
| `.claude/memory/learnings.md` | the cross-venture learning loop |
| `claude/<feature>` | the worktree branch for a parallel build |

This is a **convention, not a variable system.** Agents are plain markdown
prompts — there is no runtime substitution — so the layout is written literally
and must be kept consistent. (Earlier docs described `$VENTURE`/`$STATE`-style
variables and "paths can move without rewriting every agent"; that indirection
was never wired, so the claim is dropped. If the layout ever has to move, it's a
deliberate one-time find-and-replace across the config.) The guarantee that
actually holds is the one that matters: **one known location per kind of state**,
so no agent invents its own.

## Wall 4 — Worktree isolation per parallel build

Every parallel builder gets its own git worktree + branch
(`claude/<feature>`) + (if the stack needs it) its own ports. This means
multiple features can build at once without file collisions or git-state
corruption. Sequential single-feature work can skip the worktree; the moment
two builders run, worktrees are mandatory. When a feature merges, its worktree
is removed.

## Wall 5 — Self-improvement at the source

When something in the *system itself* goes wrong (an agent has a bad
instruction, a command misroutes), you don't just write a STATE.md note — you
fix the actual agent/command file via `/improve` (see the command). This is
Professor's `/pcm` idea in lean form: surgery at the source, gated by a
prompt-quality check AND the eval suite (see evals/BASELINE.md) so edits don't
degrade the agent. Distinct from the learning loop (which records *domain*
lessons); this wall is for fixing the *machinery*.

## Why these five and not more

Professor ships far more (token-ledger, `/wave` scheduler, saved-JS workflows,
Dr. House persona). Those earned their place in a battle-tested system but add
maintenance weight. These five are the irreducible reliability core — the 20%
that delivers 80% of the safety. The rest is documented as an upgrade path in
the README, to be added only when a real pain proves it's needed.
