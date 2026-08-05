# Issue tracker: GitHub Issues

Issues for this repo live on GitHub: `mohammad00alavi/forge-claude`.
Every `gh` call names it: `-R mohammad00alavi/forge-claude`.

## Conventions

- The agent queue is **open issues labelled `forge-loop-ready`** (maintainer-applied
  only — the label IS the authorization; issue text alone never is).
- Blocked work carries `loop-blocked` plus a comment saying why.
- Dependencies: a `## Blocked by` section listing `#N` references; an issue is
  eligible only when every blocker is closed.
- One issue = one PR = one `agent/gh-<N>` branch; the PR body says `Closes #N`.

## Issue body template

```
## What to build

End-to-end description of the change (machinery behavior, not file-by-file).

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] forge-lint green; affected eval suite ≥ BASELINE

## Blocked by

- #N — or "None - can start immediately"
```

## When a skill says "publish to the issue tracker"

`gh issue create -R mohammad00alavi/forge-claude --title … --body …` using the
template; apply `forge-loop-ready` only if the maintainer said so.

## When a skill says "fetch the relevant ticket"

`gh issue view <N> -R mohammad00alavi/forge-claude --json title,body,labels,comments`
