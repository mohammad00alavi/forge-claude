# .claude/evals/ — golden tests for Forge's own machinery

These test the SYSTEM (does /assess still tier right, does the verifier still
catch defects), not your ventures. Full discipline:
skills/forge-playbook/references/eval-harness.md

- `assess.md`, `verifier.md`, `improve.md` — golden cases per capability.
- `BASELINE.md` — pinned pass-rates; the regression reference.

MANDATORY: run the affected capability's suite BEFORE and AFTER every /improve.
If the after-score drops below baseline, the edit degraded the machinery —
revert or fix. This is what makes self-improvement safe.

Run each case 3×, take the median. Add a new case whenever a real venture
surfaces a machinery failure mode.
