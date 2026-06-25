# Code verification rubric (the objective gate)

The verifier grades code against this rubric in its own context, seeing only
the spec + the diff + the gate commands — never the builder's reasoning. This
is Anthropic's "outcomes" pattern applied to code: state what "good" is, then
check against it objectively.

## Objective gates (pass/fail — non-negotiable)
- [ ] typecheck exits 0
- [ ] lint exits 0
- [ ] test exits 0, including at least one NEW/UPDATED test that FAILS without
      the change (a test that passes regardless verifies nothing)
- [ ] build compiles
- [ ] no console.log / debugger / @ts-ignore / eslint-disable introduced
      (grep the diff)

## Spec fidelity
- [ ] Every acceptance criterion maps to a visible change or a test.
- [ ] Nothing in the diff is outside the feature's scope (no drive-by edits).
- [ ] The spec's "Unchanged" boundary was respected (drift into it = FAIL).
- [ ] Edge states handled: loading, empty, error, overflow, mobile width.

## Safety
- [ ] No secrets/keys/internal URLs in the diff.
- [ ] No forbidden paths touched (auth/payments/billing). A touched forbidden
      path is ALWAYS an **ESCALATE** — never a FAIL defect, never a silent PASS;
      a human decides on sensitive code.
- [ ] No new dependency without explicit human approval.

## Verdict
PASS (summary that lists EACH acceptance criterion and how it was confirmed — by
which test or visible change; a terse "looks good" is not a PASS) · FAIL
(numbered defects, each citing a gate / acceptance criterion / file:line) ·
ESCALATE (out-of-scope judgment call, or any forbidden path touched). Gates passing but an acceptance criterion
unmet is still a FAIL — gates are necessary, not sufficient. An opinion is
never a defect.
