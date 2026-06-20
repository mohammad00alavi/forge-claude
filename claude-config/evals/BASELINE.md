# Eval baseline — pin pass-rates here, judge changes against this

Record the median pass-rate per capability after a clean run. A change that
drops a capability 2+ cases below its baseline is a regression — investigate
before shipping. Update this file (commit it) only when scores genuinely
improve.

| Capability | Cases | Baseline pass | Last checked | Notes |
|-----------|-------|---------------|--------------|-------|
| /assess   | 6     | _unrun_       | —            | seed suite, never run yet |
| verifier  | 6     | _unrun_       | —            | seed suite, never run yet |
| /improve  | 4     | _unrun_       | —            | seed suite, never run yet |
| /fix      | 6     | _unrun_       | —            | maintain mode, never run yet |
| /research | 5     | _unrun_       | —            | STORM method, never run yet |

> These are seed cases with NO baseline yet — the suite is a floor waiting for
> its first real run. Run all three capabilities once on the current (known-good)
> v2.3 machinery to establish the baseline, then this becomes the regression
> reference for every future /improve.
