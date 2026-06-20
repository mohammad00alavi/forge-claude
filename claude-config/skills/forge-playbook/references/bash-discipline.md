# Bash discipline — keep routine commands simple so runs don't stall

## The problem this prevents

Claude Code prompts for approval on ANY bash command containing shell operators
(`&&`, `||`, `;`, `|`, `$(...)`) — separately from the allow/deny list, as a
safety guard against operators hiding harmful actions in a harmless-looking
line. So a compound command like
`command -v fnm && echo yes || echo no; which node` triggers an approval prompt
*even though every piece is read-only*, because the operators trip the guard and
no allow-list entry matches the chained whole.

This stalls otherwise-smooth runs. The fix is behavioral, not a permission
change: write routine commands simply, so they match the allow list and skip the
prompt. Forge keeps its config-enforced safety (push denied, etc.) AND runs
smoothly — without resorting to a `Bash(*)` wildcard that would dissolve the
whole model.

## The rule

**For routine, read-only work — environment detection, presence/version checks,
status reads, running a single gate — prefer SEPARATE simple commands over
operator chains.**

Do this (separate simple commands, each matches the allow list, no prompt):
```
command -v fnm
command -v volta
which node
npm run typecheck
```

Not this (one operator-chained line — trips the approval guard):
```
command -v fnm && echo "fnm present" || echo "no fnm"; which node
npm run typecheck && npm run lint && npm run test
```

When you need the result of several checks, run them as separate calls and read
each result. You lose nothing — the information is identical — and for
diagnostics you actually gain clarity, because a `||` no longer swallows which
check failed.

## The exception — operators that do REAL work are fine

This is NOT a blanket ban on operators. Keep them where the operator is doing
actual logical work, not just bundling convenience:

- **Pipes that compute:** `cat file | grep pattern | wc -l` — the `|` IS the
  operation; you can't unchain it without losing the computation. Fine to use
  (it will prompt once; that's correct — it's a real compound operation).
- **Genuinely dependent sequences:** `mkdir -p build && cd build && cmake ..` —
  where each step must not run if the previous failed. Use the chain when the
  dependency is real and matters. (Prefer running these as one intentional,
  approved command rather than faking independence.)
- **Command substitution that's essential:** `npm view $(cat .nvmrc)` — when the
  inner result is needed inline.

The test: *is the operator bundling convenience, or doing work?* Bundling →
split it. Doing work → keep it (and the one approval prompt is appropriate).

## Why not just allow everything (the Professor approach)

Professor uses `Bash(*)` — a wildcard that allows all bash, operators included,
so it never prompts. That works for Professor (a general dev tool that needs
arbitrary shell), but it's why Professor's git-push restraint has to live in
*prose* (an instruction the model is told to follow) rather than config: once
all bash is allowed, only an instruction stops a push. Forge deliberately keeps
the mechanical gate, so it keeps bash narrow and fixes the *behavior* (simple
commands) instead of widening the *permission* (allow all). Same smooth run,
stronger guarantee.
